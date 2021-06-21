$(() => {
  $(".initiative-documents .close-button").on("click", (event) => {
    $(event.target).parent().parent().remove()
  })
})
