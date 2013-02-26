(function($) {

//simple get and add text before :before element. Nothing flash  
RemoteGetAndInsertBefore = $.klass(Remote.Base, {
  initialize: function($super, options) {
    if (!options.before){ $.fbDebug(function() {console.error('before not defined during bind')}); }
    $super(options);
  },
  onclick: function(){
    this._makeRequest({url: this.element.attr('href')});
    return false;
  },
  onupdate: function(data, status) { //data will contain name of new comment element
    before = $(request.options.before);
    before.before(data);
  }
});

//simple remote update. Requires :target. Determines ID from element and find correct :targer  
RemoteAbilityChangeGetAndReqObject = $.klass(Remote.Base, {
  initialize: function($super, options) {
    if (!options.target){ $.fbDebug(function() {console.error('target not defined during bind')}); }
    options.id     = this.element.attr('id').match(/([-|\d]+)$/g);
    options.update = options.target +'_'+ options.id;
    $super(options);
  },
  onchange: function(){
    select_options = this.element.attr('options');
    opt_sel = select_options[select_options.selectedIndex].value;
    this._makeRequest({url: '/prereqs/type_objects/' + this.options.id +'/'+ opt_sel});
  }
});


RemoteGetBasePropertiesForm = $.klass(Remote.Base, {
  initialize: function($super, options) {
    if (!options.form){ $.fbDebug(function() {console.error('form not defined during bind')}); }
    $super(options);
  },
  onchange: function() {
    select_options = this.element.attr('options');
    opt_sel = select_options[select_options.selectedIndex].value;
    options = $.extend({
        data:  $(this.options.form).serializeArray(),
        method : 'GET'
      },  this.options);
      //collapse subform by toggling a blind then replace with spinner
      sub = $(this.options.update);
      this_local = this;
      sub.slideToggle(300, function() {
        sub.html('<div class="spinner"><img src="/images/spinner.gif" /></div>');
        sub.slideToggle(200, function() {
          return this_local._makeRequest(options);
        });
      });
  },
  onupdate: function($super, data, status){
    target = $(request.options.update);
    target.slideToggle(300, function() {
      $super(data, status);
      target.slideToggle(300, function() {
        $.scrollTo(target, 500);
      });
    });
  }
});

//item sub type select box behavior. Ajax query to render correct form depending on selected item.
RemoteGetItemPropertiesForm = $.klass(RemoteGetBasePropertiesForm, {
  initialize: function($super, options) {
    if (!options.form){ $.fbDebug(function() {console.error('form not defined during bind')}); }
    options.url         = '/items/properties/';
    options.evalScripts = true;
    $super(options);
  }
});

//skill sub type select box behavior. Ajax query to render correct form depending on selected item.
RemoteGetSkillPropertiesForm = $.klass(RemoteGetBasePropertiesForm, {
  initialize: function($super, options) {
    if (!options.form){ $.fbDebug(function() {console.error('form not defined during bind')}); }
    options.url         = '/skills/properties/';
    options.evalScripts = false;
    $super(options);
  }
});

//mob type select box behavior. Ajax query to render correct form depending on selected mob type.
  RemoteGetMobPropertiesForm = $.klass(RemoteGetBasePropertiesForm, {
    initialize: function($super, options) {
      if (!options.form){ $.fbDebug(function() {console.error('form not defined during bind')}); }
      options.url         = '/mobs/properties/';
      options.evalScripts = false;
      $super(options);
    }
  });


})(jQuery);
