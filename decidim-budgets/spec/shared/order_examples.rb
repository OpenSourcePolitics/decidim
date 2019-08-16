# frozen_string_literal: true

shared_examples "order" do |*options|
  subject { order }

  let(:order) { create :order, component: component }
  let(:component) { create(:budget_component) }
  let(:category) { create(:category, participatory_space: component.participatory_space) }
  let(:other_category) { create(:category, participatory_space: component.participatory_space) }
  let(:projects_per_category_treshold) do
    {
      category.id.to_s => "1",
      other_category.id.to_s => "0"
    }
  end

  describe "validations" do
    it "is valid" do
      expect(subject).to be_valid
    end

    it "is invalid when user is not present" do
      subject.user = nil
      expect(subject).to be_invalid
    end

    it "is invalid when component is not present" do
      subject.component = nil
      expect(subject).to be_invalid
    end

    it "is unique for each user and component" do
      subject.save
      new_order = build :order, user: subject.user, component: subject.component
      expect(new_order).to be_invalid
    end

    context "when total budgets is activated" do
      let(:component) { create(:budget_component, settings: settings) }

      shared_examples "validating projects_per_category_treshold when vote_per_category is enabled" do
        before do
          new_settings = component.settings.to_h.merge(
            vote_per_category: true,
            projects_per_category_treshold: projects_per_category_treshold
          )
          component.update(settings: new_settings)
        end

        it "must reach the projects per category treshold when checked out" do
          subject.projects << create(:project, component: component, category: other_category, budget: 35)
          subject.projects << create(:project, component: component, category: other_category, budget: 35)

          expect(subject).to be_valid
          subject.checked_out_at = Time.current
          expect(subject).to be_invalid
        end

        it "can exceed the projects per category treshold when checked out" do
          subject.projects << create(:project, component: component, category: category, budget: 35)
          subject.projects << create(:project, component: component, category: category, budget: 35)

          expect(subject).to be_valid
          subject.checked_out_at = Time.current
          expect(subject).to be_valid
        end
      end

      context "when vote by total budget" do
        if options.include? :total_budget
          let(:settings) do
            {
              vote_per_budget: true,
              total_budget: 100,
              vote_threshold: 50
            }
          end

          it "can't exceed a maximum order value" do
            project1 = create(:project, component: subject.component, budget: 100)
            project2 = create(:project, component: subject.component, budget: 20)

            subject.projects << project1
            subject.projects << project2

            expect(subject).to be_invalid
          end

          it "can't be lower than a minimum order value when checked out" do
            project1 = create(:project, component: subject.component, budget: 20)

            subject.projects << project1

            expect(subject).to be_valid
            subject.checked_out_at = Time.current
            expect(subject).to be_invalid
          end

          it_behaves_like "validating projects_per_category_treshold when vote_per_category is enabled"
        end
      end

      context "when vote by total projects" do
        if options.include? :total_projects
          let(:settings) do
            {
              vote_per_budget: false,
              total_budget: 100,
              vote_threshold: 50,
              vote_per_project: true,
              total_projects: 2
            }
          end

          it "can't exceed the total_projects value" do
            project1 = create(:project, component: subject.component)
            project2 = create(:project, component: subject.component)
            project3 = create(:project, component: subject.component)

            subject.projects << project1
            subject.projects << project2
            subject.projects << project3

            expect(subject).to be_invalid
          end

          it "can't be lower than total_projects value when checked out" do
            project1 = create(:project, component: subject.component)

            subject.projects << project1

            expect(subject).to be_valid
            subject.checked_out_at = Time.current
            expect(subject).to be_invalid
          end

          it "can exceed the total_budget value" do
            project1 = create(:project, component: subject.component, budget: 99_999)
            project2 = create(:project, component: subject.component, budget: 99_999)

            subject.projects << project1
            subject.projects << project2

            expect(subject).to be_valid
          end

          it "can be lower than the minimum_budget value when checked out" do
            project1 = create(:project, component: subject.component, budget: 0)
            project2 = create(:project, component: subject.component, budget: 0)

            subject.projects << project1
            subject.projects << project2

            subject.checked_out_at = Time.current
            expect(subject).to be_valid
          end

          it_behaves_like "validating projects_per_category_treshold when vote_per_category is enabled"
        end
      end
    end
  end

  describe "#projects_per_category" do
    it "groups the projects per category and counts them" do
      subject.projects << create(:project, component: component, category: category)
      subject.projects << create(:project, component: component, category: other_category)

      expect(subject.projects_per_category).to eq(category.id => 1, other_category.id => 1)
    end
  end

  shared_examples "projects per category treshold" do
    it "returns a Hash with keys and values as Integer" do
      is_integer = proc { |e| e.is_a?(Integer) }

      expect(subject.keys.all?(&is_integer)).to eq(true)
      expect(subject.values.all?(&is_integer)).to eq(true)
    end

    it "contains only positive values" do
      expect(subject.values.all?(&:positive?)).to eq(true)
      expect(subject).not_to include(other_category.id => 0)
    end
  end

  describe "::projects_per_category_treshold" do
    before do
      component.update(settings: { projects_per_category_treshold: projects_per_category_treshold })
    end

    it_behaves_like "projects per category treshold" do
      subject { Decidim::Budgets::Order.projects_per_category_treshold(component) }
    end
  end

  describe "#projects_per_category_treshold" do
    before do
      component.update(settings: { projects_per_category_treshold: projects_per_category_treshold })
    end

    it_behaves_like "projects per category treshold" do
      subject { order.projects_per_category_treshold }
    end
  end

  describe "#total_budget" do
    context "when vote by total budget" do
      if options.include? :total_projects

        let(:total_projects_component) { create(:budget_component, :with_vote_per_project) }

        it "returns the sum of project budgets" do
          subject.projects << build(:project, component: subject.component)

          expect(subject.total_projects).to eq(subject.projects.count(&:budget))
        end
      end
    end

    context "when vote by total project" do
      if options.include? :total_budget
        let(:total_budget_component) { create :order, component: create(:budget_component) }

        it "returns the sum of project budgets" do
          subject.projects << build(:project, component: subject.component)

          expect(subject.total_budget).to eq(subject.projects.sum(&:budget))
        end
      end
    end
  end

  describe "#checked_out?" do
    context "when vote by total budget" do
      if options.include? :total_budget
        it "returns true if the checked_out_at attribute is present" do
          subject.checked_out_at = Time.zone.now
          expect(subject).to be_checked_out
        end
      end
    end

    context "when vote by total project" do
      if options.include? :total_projects
        let(:total_projects_component) { create(:budget_component, :with_vote_per_project) }

        it "returns true if the checked_out_at attribute is present" do
          subject.checked_out_at = Time.zone.now
          expect(subject).to be_checked_out
        end
      end
    end
  end
end
