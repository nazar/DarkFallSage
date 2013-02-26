jQuery.noConflict();

tree_settings = {
  ui: {
    context: [],
    theme_name: 'darkfall',
    theme_path	: '/javascripts/jquery/tree/themes/'
  },
  callback: {
    onselect:  function(node, tree_obj) { window.location = node.firstChild.href; }
  }
}

