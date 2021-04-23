const $authors = $(".author--hidden")
const $seeMore = $(".author__see-more")
const $seeMoreLink = $(".authors_see-more-link")
const $seeLessLink = $(".author__see-less-link")

$(() => {
  $seeMoreLink.
    add($seeLessLink).
    on("click", () => {
      $authors.toggleClass("hide")
      $seeMore.toggleClass("hide")
      $seeLessLink.toggleClass("hide")
    })
});
