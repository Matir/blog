document.addEventListener("DOMContentLoaded", function(event){
  var searchInput = document.getElementById('searchQuery');
  if (searchInput) {
    var sjs = SimpleJekyllSearch({
      searchInput: searchInput,
      resultsContainer: document.getElementById('searchResults'),
      json: '/index.json',
      searchResultTemplate: '<li><a href="{url}"><b>{title}</b></a> - {date}<p>{description}</p></li>',
      success: () => {}
    });
  }
});
