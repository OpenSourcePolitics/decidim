# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/0.18-stable)

**Added**:

**Changed**:

**Fixed**:

- **decidim-proposals**: Fix: prevent ransack gem to upgrade to 2.3 as breaks searches with amendments. [#5303](https://github.com/decidim/decidim/pull/5303)
- **decidim-admin**, **decidim-forms**: Fix adding answer options to a new form [#5283](https://github.com/decidim/decidim/pull/5283)
- **decidim-core**, **decidim-proposals**: When rendering the admin log for a Proposal, use the title from extras instead of crashing, when proposal has been deleted. [#5277](https://github.com/decidim/decidim/pull/5277)
- **decidim-core**: Fix CVE-2015-9284 Omniauth issue [#5287](https://github.com/decidim/decidim/pull/5287)

**Added**:

- **decidim-proposals**: Add geolocation to proposals export. [#572](https://github.com/OpenSourcePolitics/decidim/pull/572)
- **decidim-admin**: Add pagination to private user list. [\#345](https://github.com/OpenSourcePolitics/decidim/pull/345)
- **decidim-budgets**: Re-introduce vote on budget by number of project.[\#330](https://github.com/OpenSourcePolitics/decidim/pull/330)
- **decidim-debates**: Allow debates to be reported [\#199](https://github.com/OpenSourcePolitics/decidim/pull/199)
- **decidim-proposals**: Allow proposals location to be changed on a map [\#296](https://github.com/OpenSourcePolitics/decidim/pull/296)
- **decidim-participatory_processes**: Ability to order processes in the back-office [#189](https://github.com/OpenSourcePolitics/decidim/pull/189)
- **decidim-debates**: add export feature to debates [#270](https://github.com/OpenSourcePolitics/decidim/pull/270)
- **decidim-debates**: Allow debates to be reported [#199](https://github.com/OpenSourcePolitics/decidim/pull/199)
- **decidim-core**: Banner uploader has been changed in [\#150](https://github.com/OpenSourcePolitics/decidim/pull/150)
- **decidim-core**: Avater uploader has been changed in [\#147](https://github.com/OpenSourcePolitics/decidim/pull/147)
- **decidim-core**: Now have a quality setting which can be used by adding `process quality:%%` where %% is  your desired percentage of quality
- **decidim-core** : Add an initializer otion to skip first login authorization [\#176](https://github.com/OpenSourcePolitics/decidim/pull/176)
- **decidim-admin**: Add link to user profile and link to conversation from admin space. [\#208](https://github.com/OpenSourcePolitics/decidim/pull/208)
- **decidim-core**: Add a config accessor for admin upload attachment
[\#258](https://github.com/OpenSourcePolitics/decidim/issues/258)


**Changed**:

- ~~**decidim-proposals**: Remove caps first validator. Format title and body without any intervention from the user [\#259](https://github.com/OpenSourcePolitics/decidim/pull/259)~~
- **decidim-participatory_processes**: Make process moderators receive notifications about flagged content [\#228](https://github.com/OpenSourcePolitics/decidim/pull/228)
- **decidim-participatory_processes**: Add customised action button text regarding to the steps [\#257](https://github.com/OpenSourcePolitics/decidim/issues/257)
 - **decidim-participatory_processes**: Make process moderators receive notifications about flagged content [\#228](https://github.com/OpenSourcePolitics/decidim/pull/228)

**Fixed**:

- **decidim-proposals**: Fix stats display.[\#356](https://github.com/OpenSourcePolitics/decidim/pull/356)
- **decidim-debates**: Fix stats display.[\#356](https://github.com/OpenSourcePolitics/decidim/pull/356)
- **decidim-debates**: Fix stats display.[\#356](https://github.com/OpenSourcePolitics/decidim/pull/356)
- **decidim-core**: Fix comments count when a comment has been moderated [\#349](https://github.com/OpenSourcePolitics/decidim/pull/349)
- **decidim-participatory_processes**: Fix participatory processes pagination[\#351](https://github.com/OpenSourcePolitics/decidim/pull/351)
- **decidim-core**: Fix newsletter notification modal [\#342](https://github.com/OpenSourcePolitics/decidim/pull/342)
- **decidim-proposals**: Fix responsive car preview for proposals[\#325](https://github.com/OpenSourcePolitics/decidim/pull/325)
- **decidim-budgets**: Add hyphens to budget card. [\#305](https://github.com/OpenSourcePolitics/decidim/pull/305)
- **decidim-admin**: Fix issue when updating a navbar link. [\#310](https://github.com/OpenSourcePolitics/decidim/pull/310)
- **decidim-surveys**: Fix validation issue on survey sortable question [\#314](https://github.com/OpenSourcePolitics/decidim/pull/314)
- **decidim-surveys**: Fix issue when copying. [\#308](https://github.com/decidim/decidim/pull/308)
- **decidim-proposals**: Proposal creation and update fixes: [\#3744](https://github.com/decidim/decidim/pull/3744)
  - Fix `CookieOverflow` in wizard steps
  - Fix `proposal_length` validation on create_step
  - Fix ability to update proposal attachment
  - Fix `has_address` checked and `address` on invalid form
  - Fix ability to update the proposal's `author/user_group`
- **decidim-admin**: Add email validation to ManagedUserPromotionForm. [\#295](https://github.com/OpenSourcePolitics/decidim/pull/295)
- **decidim-budgets**: Fix display of budgets when votes count is activated. [\#268](https://github.com/OpenSourcePolitics/decidim/pull/268)
- **decidim-accountability**: Fix accountability progress to be between 0 and 100 if provided. [\#3952](https://github.com/decidim/decidim/pull/3952)
- **decidim-participatory_processes**: Fix hastag display on participatory processes. [\#200](https://github.com/OpenSourcePolitics/decidim/pull/200)
- **decidim-core**: Fix test consistency [#222](https://github.com/OpenSourcePolitics/decidim/pull/222)
- **decidim-core**: Add shinier signature. [#186](https://github.com/OpenSourcePolitics/decidim/pull/186)
- **decidim-comments**: Comments not displayed with IE [#432](https://github.com/OpenSourcePolitics/decidim/issues/432)

**Backported**:

**decidim-proposals**: Fix collaborative draft attachment when attachments are enabled after collaborative draft creation [\#503](https://github.com/OpenSourcePolitics/decidim/pull/503)
- **decidim-core**: Don't send emails to deleted users [\#364](https://github.com/OpenSourcePolitics/decidim/pull/364)
- **decidim-core**: Fix notifications sending when there's no component. [\#348](https://github.com/opensourcepolitics/decidim/pull/348)
- **decidim-surveys**: Allow deleting surveys components when there are no answers [#211](https://github.com/OpenSourcePolitics/decidim/pull/211)
- **decidim-proposals**: Hide withdrawn proposals from index [\#4012](https://github.com/decidim/decidim/pull/4012)
- **decidim-proposals**: Hide withdrawn proposals from index [\#4012](https://github.com/decidim/decidim/pull/4012)
- **decidim-core**: Allows users with admin access to preview unpublished components [\#209](https://github.com/OpenSourcePolitics/decidim/pull/209)
- **decidim-core**: Fix proposal mentioned notification. [\#4281](https://github.com/decidim/decidim/pull/4281)
- **decidim-core**: Use org default locale as fallback on emails [#4892](https://github.com/decidim/decidim/pull/4892)

## [Unreleased](https://github.com/decidim/decidim/tree/0.11-stable)
## [Unreleased](https://github.com/decidim/decidim/tree/0.15-stable)

**Fixed**:

- **decidim-meetings**: Fix meetings form when only one locale is available [\#4625](https://github.com/decidim/decidim/pull/4625)
- **decidim-core**: Update Ransack to make it work with Rails 5.2.2 [\#4683](https://github.com/decidim/decidim/pull/4683)
- **decidim-core**: Remove `current_feature` [\#4680](https://github.com/decidim/decidim/pull/4680)
- **decidim-meetings**: Filter meeting by end time instead of start time [\#4703](https://github.com/decidim/decidim/pull/4703)

## [0.15.1](https://github.com/decidim/decidim/tree/v0.15.1)

**Fixed**:

- **decidim-meetings**: Change title to description in meetings admin form. [\#4484](https://github.com/decidim/decidim/pull/4484)
- **decidim-meetings**: Fix title and description fields in admin form. [\#4547](https://github.com/decidim/decidim/pull/4547)
- **decidim-proposals**: Fix vote-rerendering on a proposal's page [\#4558](https://github.com/decidim/decidim/pull/4558)
- **decidim-admin**: Fix image updating in content blocks [\#4561](https://github.com/decidim/decidim/pull/4561)
- **decidim-core**: Fix tabs with inputs with invalid characters [\#4561](https://github.com/decidim/decidim/pull/4561)
**Removed**:

## [0.18.0](https://github.com/decidim/decidim/tree/v0.18.0)

### Upgrade notes

#### Participants metrics

After running the migrations, you can run the following code from the console to recalculate participants metrics (they should increase). It may take a while to complete.

```ruby
days = (Date.parse(2.months.ago.to_s)..Date.yesterday).map(&:to_s)
Decidim::Organization.find_each do |organization|
  old_metrics = Decidim::Metric.where(organization: organization, metric_type: "participants")
  days.each do |day|
    new_metric = Decidim::Metrics::ParticipantsMetricManage.new(day, organization)
    ActiveRecord::Base.transaction do
      old_metrics.where(day: day).delete_all
      new_metric.save
    end
  end
end
```

**Added**:

- **decidim-consultations**, Add buttons fot better Questions navigation. [#5112](https://github.com/decidim/decidim/pull/5112)
- **decidim-core**, Add rake task to recalculate all metrics since some specific date. [#5117](https://github.com/decidim/decidim/pull/5117)
- **decidim-core**, Add instructions to recalculate participants metrics. [#5110](https://github.com/decidim/decidim/pull/5110)
- **decidim-core**, **decidim-admin**, Add Selective Newsletter and allow Space admins to manage them. [#5039](https://github.com/decidim/decidim/pull/5039)
- **decidim-core** Persistence related documentation for Metrics. [\#5108](https://github.com/decidim/decidim/pull/5108)
- **decidim-core** Add optional parameter :col_sep to CSV exporter [\#5089](https://github.com/decidim/decidim/pull/5089)
- **decidim-meetings** Let user groups join meetings [\#5060](https://github.com/decidim/decidim/pull/5060)
- **decidim-assemblies**, **decidim-participatory_processes** Reorganize admin form [\#5068](https://github.com/decidim/decidim/pull/5068)
- **decidim-assemblies**, **decidim-participatory_processes** Table headers sortable links [\#5010](https://github.com/decidim/decidim/pull/5010)
- **decidim-assemblies**, **decidim-participatory_processes** Filter spaces by scope and area [\#5047](https://github.com/decidim/decidim/pull/5047)
- **decidim-admin**: Do not allow to delete areas when they have dependent spaces. [#5041](https://github.com/decidim/decidim/pull/5041)
- **decidim-assemblies**, **decidim-conferences**, **decidim-participatory_processes** Space CTA button text changes when no components [\#5006](https://github.com/decidim/decidim/pull/5006)
- **decidim-participatory_processes**: Add a select field for assign an area to participatory processes [#5011](https://github.com/decidim/decidim/pull/5011)
- **decidim-accountability**: Also display the main scope as a filter for accountability results [#5022](https://github.com/decidim/decidim/pull/5022)
- **decidim-system**: Add custom SMTP settings for multitenant [#4698](https://github.com/decidim/decidim/pull/4698)
- **decidim-proposals**: Add proposal answers to the proposal export [#5139](https://github.com/decidim/decidim/pull/5139)
- **decidim-core**: Provide "good" password rules [#5106](https://github.com/decidim/decidim/pull/5106)
- **decidim-surveys**: Added a setting to surveys to allow unregistered (aka: anonymous) users to answer a survey. [\#4996](https://github.com/decidim/decidim/pull/4996)

**Changed**:

- **decidim-accountability**, **decidim-core**, **decidim-proposals**: Improve UX for diff views of versions. [#5149](https://github.com/decidim/decidim/pull/5149)
- **decidim-core**: Allow for extension in Decidim::User::ROLES. [#5133](https://github.com/decidim/decidim/pull/5133)
- **decidim-core**: PermissionsRegistry introduced to enable reconfiguration of permission_class_chain. [#5069](https://github.com/decidim/decidim/pull/5069)
- **decidim-core**: Change attachment photo image alt texts to title instead of description. [#5043](https://github.com/decidim/decidim/pull/5043)
- **decidim-comments**: Allow cancelling a vote on a comment. [#5042](https://github.com/decidim/decidim/pull/5042)
- **decidim-initiatives**: Add styles inline in PDF document of signatures [#5103](https://github.com/decidim/decidim/pull/5103)
- **decidim-core**: Update nobspw [#5227](https://github.com/decidim/decidim/pull/5227)
- **decidim-accountability**, **decidim-assemblies**, **decidim-consultations**, **decidim-core**, **decidim-proposals**, **decidim-debates**, **decidim-dev**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory_processes**, **decidim-proposals**, **decidim-sortitions**, **decidim_app-design**: Change: social share button default sites [\#5270](https://github.com/decidim/decidim/pull/5270)

**Fixed**:

- **decidim-admin**: Fix: Proposals component form introduced regression [\#5180](https://github.com/decidim/decidim/pull/5180)
- **decidim-admin**: Fix: Link `form.js` in `assets/config/decidim_admin_manifest.js` [\#5165](https://github.com/decidim/decidim/pull/5165)
- **decidim-core**: Fix: potential loop redirection when accepting TOS agreement on multi-languages sites [\#5162](https://github.com/decidim/decidim/pull/5162)
- **decidim-assemblies**: Fix: Include asterisk in the required field `position` for `AssemblyMemberForm`. [\#5164](https://github.com/decidim/decidim/pull/5164)
- **decidim-admin**: Fix: disallow enabling `ParticipatoryText` on component when there are proposals [\#5134](https://github.com/decidim/decidim/pull/5134)
- **decidim-meetings**: Fix registration form in duplicated meeting [\#5136](https://github.com/decidim/decidim/pull/5136)
- **decidim-meetings**: Fix meeting minutes related information in public view [\#5137](https://github.com/decidim/decidim/pull/5137)
- **decidim-meetings**: Fix `deliver_now` call on `send_email_confirmation` [\#5111](https://github.com/decidim/decidim/pull/5111)
- **decidim-admin**: fix Decidim::Admin::NewsletterRecipient query [\#5109](https://github.com/decidim/decidim/pull/5109)
- **decidim-proposals**: Fix participatory text form. [#5094](https://github.com/decidim/decidim/pull/5094)
- **decidim-assemblies**: Add class `card--stack` to assemblies when have children assemblies. [#5093](https://github.com/decidim/decidim/pull/5093)
- **decidim-proposals**: Fix proposal participants metrics. [#5048](https://github.com/decidim/decidim/pull/5048)
- **decidim-comments**: Don't show a second reply button when comment is hidden. [#5045](https://github.com/decidim/decidim/pull/5045)
- **decidim-core**: Fix CSS transparencies using customized colors. [\#5071](https://github.com/decidim/decidim/pull/5071)
- **decidim-core**, **decidim-proposals**: Fix: show existing amendments when amendments feature is disabled [\#5070](https://github.com/decidim/decidim/pull/5070)
- **decidim-assemblies**: Fix admin assemblies form. [\#5054](https://github.com/decidim/decidim/pull/5054)
- **decidim-core**: Fix repeated amendments notifications. [\#5001](https://github.com/decidim/decidim/pull/5001)
- **decidim-core**: Fix amendments forms: show error messages and render hashtags. [#4951](https://github.com/decidim/decidim/pull/4951)
- **decidim-comments**: Fixes that as a normal user (no private user) I can comment on a private assembly where is available. [#4924](https://github.com/decidim/decidim/pull/4924)
- **decidim-accountability**: Handle special case when all children weight are nil on accountability. [#5026](https://github.com/decidim/decidim/pull/5026)
- **decidim-proposals**: Filter emendations by rendering only amendments. [#5025](https://github.com/decidim/decidim/pull/5025)
- **decidim-proposals**: Add documents folder in proposals manifest for precompile assets. [#5015](https://github.com/decidim/decidim/pull/5015)
- **decidim-core**: Fix user notification and interest settings on IE11. [#5044](https://github.com/decidim/decidim/pull/5044)
- **decidim-admin**, **decidim-forms**, **decidim-meetings**: Fix dynamic fields components on IE11. [#5052](https://github.com/decidim/decidim/pull/5052)
- **decidim-core**: Fix possible NoMethodErrors in the notification jobs filling logs. [#5083](https://github.com/decidim/decidim/pull/5083)
- **decidim-participatory_processes**: Fix step CTA URL when abse URL had params [#5082](https://github.com/decidim/decidim/pull/5082)
- **decidim-admin**: Ensure static pages slugs are relative paths [#5085](https://github.com/decidim/decidim/pull/5085)
- **decidim-accountability**: Remove useless button on the admin page for accountability statuses [#5099](https://github.com/decidim/decidim/pull/5099)
- **decidim-budgets**: Fix import of proposals to budget projects [#5097](https://github.com/decidim/decidim/pull/5097)
- **decidim-core**: Escape fingerprint content [#5146](https://github.com/decidim/decidim/pull/5146)
- **decidim-initiatives**: Escape hashtag content [#5150](https://github.com/decidim/decidim/pull/5150)
- **decidim-sortitions**: Fix: Creating a Sortition ignores categories [#5412](https://github.com/decidim/decidim/pull/5412)
- **decidim-core**: Fix seeds and typo in ActionAuthorizer [#5168](https://github.com/decidim/decidim/pull/5168)
- **decidim-proposals**: Fix seeds [#5168](https://github.com/decidim/decidim/pull/5168)
- **decidim-core**: Fix user names migration [#5210](https://github.com/decidim/decidim/pull/5210)
- **decidim-core**: Fix empty sender SMTP settings [#5260](https://github.com/decidim/decidim/pull/5260)
- **decidim-core**: Fix user names migration [#5209](https://github.com/decidim/decidim/pull/5209)
- **decidim-proposals**: Fix proposals accepted stat when they include hidden proposals [#5276](https://github.com/decidim/decidim/pull/5276)
- **decidim-forms**: Fix adding answer options to a new form [#5275](https://github.com/decidim/decidim/pull/5275)
- **decidim-core**: Add missing locales when creating a new user group [#5262](https://github.com/decidim/decidim/pull/5262)
- **decidim-core**: Fix CVE-2015-9284 Omniauth issue [#5284](https://github.com/decidim/decidim/pull/5284)
- **decidim-comments**, **decidim-core**, **decidim-verifications**, **decidim-initiatives**: Bugfixing [#5213](https://github.com/decidim/decidim/pull/5213)
- **decidim-admin**: Fix managed users stolen identities with users having the same name [#5318](https://github.com/decidim/decidim/pull/5318)
- **decidim-core**: Fix usernames migration [#5321](https://github.com/decidim/decidim/pull/5321)
- **decidim-accountability**, **decidim-core**, **decidim-proposals**, **decidim-dev**, **decidim-admin**, **decidim-consultations**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Multiple bugfixes [\#5329](https://github.com/decidim/decidim/pull/5329)
- **decidim-core**: Fix rendering when custom colors exist [#5347](https://github.com/decidim/decidim/pull/5347)
- **decidim-core**: Fix component generator [#5348](https://github.com/decidim/decidim/pull/5348)
- **decidim-consultations**: Fix: current_participatory_space raises error in ConsultationsController.[\#5513](https://github.com/decidim/decidim/pull/5513)

**Removed**:

## Previous versions

Please check [0.17-stable](https://github.com/decidim/decidim/blob/0.17-stable/CHANGELOG.md) for previous changes.
