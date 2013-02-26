//helpers
  var multi = 57.295779513082320876798154814114;

  var CustomGetTileUrl = function(point, zoom) {
    return "/tiles/" + zoom + "_" + point.x + "_" + point.y + ".jpg";
  }

  var lng2x = function(x) {
    return multi * (x * Math.PI / 180);
  }
  var x2lng = function(x){
    return (x*180/Math.PI)/multi;
  }
  var lat2y = function (y)  {
    return multi * (Math.log((1 + Math.sin(y * Math.PI / 180)) / (1 - Math.sin(y * Math.PI / 180))) / 2);
  }
  var y2lat = function(y) {
    y = y/(180/Math.PI);
    return (Math.PI/2-2*Math.atan(Math.exp(y)))*180/Math.PI * -1;
  }

  var gloc = function (lat, lng) {
    var xoffset = 0.0019444444444444444444444444444444;
    var yoffset = 0.0019444444444444444444444444444444;
    var xratio = 540;
    var yratio = 540;
    if (lng < 0) {
      var x = (((lng / xratio) - xoffset) * 60);
    } else {
      var x = (((lng / xratio) - xoffset) * 60);
    }
    if (x < 0) {
      var x = x * -1;
      var xdir = "W";
    } else {
      var xdir = "E";
    }
    var xmin = Math.floor(x);
    var xsec = (x - xmin) * 60;
    if (lat > 0) {
      y = ((((180 - Math.abs(lat)) / yratio) - yoffset) * 60);
    } else {
      y = ((((Math.abs(lat) + 180) / yratio) - yoffset) * 60);
    }
    if (y < 0) {
      var y = y * -1;
      var ydir = "N";
    } else {
      var ydir = "S";
    }
    ymin = Math.floor(y);
    ysec = (y - ymin) * 60;

    return [xmin,xsec,xdir,ymin,ysec,ydir];
  }

  var uloc = function (xm, xs, xd, ym, ys, yd) {
    var xoffset = 0.0019444444444444444444444444444444;
    var yoffset = 0.0019444444444444444444444444444444;
    var xratio = 540;
    var yratio = 540;
    var remove = 180;
    var xm = xm;
    var xs = xs;
    var xd = xd;
    var ym = ym;
    var ys = ys;
    var yd = yd;
    if (xd == "W") {
      var x = (((((xs / 60) + xm) / 60) * -1) + xoffset) * xratio;
    } else {
      var x = ((((xs / 60) + xm) / 60) + xoffset) * xratio;
    }
    var y = ((((((ys / 60) + ym) / 60) + yoffset) * yratio) - remove) * -1;
    //
    return [x,y];
  }

  var coordsToTitle = function(coords) {
    return parseFloat(coords[0]).toFixed(0) +"' "+ parseFloat(coords[1]).toFixed(2) +'" '+ coords[2] +' - '+
           parseFloat(coords[3]).toFixed(0) +"' "+ parseFloat(coords[4]).toFixed(2) +'" '+ coords[5];
  }

//base class
var GoogleBaseMap = Class.create();

GoogleBaseMap.prototype = {
  initialize: function() { 
    this.init.call(arguments);
  },
  init: function(map_div) {
    if (map_div != undefined) {
      this.centered = false;
      this.rescale  = true;
      //create the google map object
      if (GBrowserIsCompatible()) {

        stdIcon = {
          shadow:'http://www.google.com/mapfiles/shadow50.png',
          iconSize: new GSize(20, 34),
          shadowSize: new GSize(37, 34),
          iconAnchor: new GPoint(9, 34),
          infoWindowAnchor:new GPoint(9, 2)
        };
        this.iconItem = new GIcon(stdIcon);
        this.iconItem.image = '/images/marker-item.png';
        this.iconMob = new GIcon(stdIcon);
        this.iconMob.image = '/images/marker-mob.png';
        this.iconPoi = new GIcon(stdIcon);
        this.iconPoi.image = '/images/marker-poi.png';

        this.map = new GMap2($(map_div));
        this.map.enableScrollWheelZoom();
        var copyCollection = new GCopyrightCollection('Darkfall Sage Map');
        var copyright = new GCopyright(1, new GLatLngBounds(new GLatLng(-90, -180), new GLatLng(90, 180)), 0, "&copy; 2009 DarkfallSage.com and DarkfallOnline.com");
        copyCollection.addCopyright(copyright);

        var tilelayers = [new GTileLayer(copyCollection, 2, 6)];
        tilelayers[0].getTileUrl = CustomGetTileUrl;
        tilelayers[0].getOpacity = function () { return 1.00;};
        tilelayers[0].isPng = function() { return false;};

        var GMapTypeOptions = new Object();
        GMapTypeOptions.minResolution = 2;
        GMapTypeOptions.maxResolution = 6;
        GMapTypeOptions.errorMessage = "Here be dragons";

        var custommap = new GMapType(tilelayers, new GMercatorProjection(22), "Darkfall Sage", GMapTypeOptions);
        custommap.getTextColor = function() { return "#ffffff"; };
        this.map.setCenter(new GLatLng(0, 0), 2, custommap);
        this.map.addControl(new GLargeMapControl());
        this.map.addMapType(custommap);
        //
        this.map.enableDoubleClickZoom();
        this.map.enableContinuousZoom();
        //
        return this;
      } else {
        alert('Google Maps not supported on this browser.');
        return false;
      }
    } else {
      return false;
    }
  },
  //surface Google's map methods
  addControl: function(obj) {
    this.map.addControl(obj);
  },
  setCenterCoords: function( lat, lon, level){
    this.map.setCenter(GPoint(lat,lon), level);
  },
  setCenter: function(point, level) {
    this.map.centerAndZoom(point,level);
  },
  //abstract methods...don't call
  setupMap: function() {
    alert('Called abstract method. Call appropriate class method instead');
  },
  setup: function() {
    this.addScaleControl();
    this.addMapTypeControl();
    this.map.enableDoubleClickZoom();
    this.map.enableContinuousZoom();
  },
  //controls
  addSmallMapControl: function() {
    this.addControl(new GSmallMapControl());
  },
  addLargeMapControl: function() {
    this.addControl(new GLargeMapControl());
  },
  addMapTypeControl: function() {
    this.addControl(new GMapTypeControl())
  },
  addSmallZoomControl: function() {
    this.addControl(new GSmallZoomControl());
  },
  addScaleControl: function() {
    this.addControl(new GScaleControl());
  },
  addOverviewControl: function() {
    this.addControl(new GOverviewMapControl());
  },
  //  virtual methods
  addMarker: function(row) {      
    coords = row.split('^');
    ucords = uloc(parseFloat(coords[0]),parseFloat(coords[1]),coords[2],parseFloat(coords[3]),parseFloat(coords[4]),coords[5]);
    title = coordsToTitle(coords)
    if (coords[6] != '') {title = coords[6] +', ' + title;}
    marker = new GMarker(new GLatLng(y2lat(ucords[1]), ucords[0]), {title: title});
    return marker;
  },
  getMapType: function() {
    return G_NORMAL_MAP;
  },
  getZoomLevel: function(bounds) {
    return this.map.getBoundsZoomLevel(bounds);
  },
  //methods
  queryMarkerData: function (qryUrl){
    this.queryUrl = qryUrl;
    GDownloadUrl(this.queryUrl, this.onDataLoad.bind(this) )
  },
  requeryMarkerData: function() {
    this.rescale = false;
    if (this.queryUrl) {this.queryMarkerData(this.queryUrl);}  
  },
  //events
  onDataLoad: function(data, responseCode) {
    if (data != '-1') {
      markers = data.split(';');
      if (markers.length > 0) {
        batch   = [];
        for (var i = 0; i < markers.length; i++) {
          if (marker = this.addMarker(markers[i])) { batch.push(marker); }  
        }
        //center map on first marker
        this.map.clearOverlays();
        if (batch.length > 0) {
          if (this.rescale) { this.map.setCenter(batch[0].getPoint(), 2);}
          //
          var bounds = new GLatLngBounds(); 
          var t = this;
          batch.each( function(value,index){ 
              bounds.extend(value.getPoint());
              t.map.addOverlay(value); 
            }          
          )
          if (this.rescale) {t.map.setCenter(bounds.getCenter(), t.getZoomLevel(bounds));} 
        } 
      }
    } else {
      this.map.clearOverlays();
      this.map.setCenter(new GLatLng(0, 0), 2);
    }
  }
};

var GoogleSmallMap = Class.create();
GoogleSmallMap.prototype=Object.extend(
  new GoogleBaseMap(),
  { 
    initialize: function(map_div) { 
      this.init(map_div);
    }, 
    setupMap: function() {
      this.setup();
      this.addSmallMapControl();
    }
  } 
);

var GoogleLargeMap = Class.create();
GoogleLargeMap.prototype=Object.extend(
  new GoogleBaseMap(),
  { 
    initialize: function(map_div) { 
      this.init(map_div);
    }, 
    setupMap: function() {
      this.setup();
      this.addLargeMapControl();
      this.addOverviewControl();
    }
  } 
);

//editor class

var GoogleSmallMapEditor = Class.create();
GoogleSmallMapEditor.prototype=Object.extend(
  new GoogleSmallMap(), 
  {
    initialize: function(map_div) { 
      this.init(map_div);
      this.hookControls();
      GEvent.addListener(this.map, "click", this.OnEditorMapClick.bind(this));
    },
    hookControls: function(){
      //opinionated... assumed set naming convension
      this.title = $('title');
      this.xm    = $('xm');
      this.xs    = $('xs');
      this.xd    = $('xd');
      this.ym    = $('ym');
      this.ys    = $('ys');
      this.yd    = $('yd');
      this.lat   = $('lat');
      this.lng   = $('lng');
    },
    //events
    OnEditorMapClick: function(marker, point) {
      if (point != undefined ) {
        lng = lng2x(point.lng());
        lat = lat2y(point.lat());
        coords = gloc(lat, lng);
        //update DOM objects
        this.xm.value = coords[0];
        this.xs.value = coords[1];
        this.xd.value = coords[2];
        this.ym.value = coords[3];
        this.ys.value = coords[4];
        this.yd.value = coords[5];
        this.lat.value = lat;
        this.lng.value = lng;
      }
    },
    requeryMarkerDataAndClear: function(){
      this.requeryMarkerData();
      this.title.value = '';
      this.xm.value = '';
      this.xs.value = '';
      this.xd.value = '';
      this.ym.value = '';
      this.ys.value = '';
      this.yd.value = '';
    }
  }
);

//view class with info windows

var GoogleMapViewer = Class.create();
GoogleMapViewer.prototype=Object.extend(
  new GoogleLargeMap(), 
  {
    initialize: function(map_div) { 
      this.init(map_div);
    },
    //override
    addMarker: function(row) {
      coords = row.split('^');
      ucords = uloc(parseFloat(coords[0]),parseFloat(coords[1]),coords[2],parseFloat(coords[3]),parseFloat(coords[4]),coords[5]);
      title = coordsToTitle(coords)
      if (coords[6] != '') {title = coords[6] +', ' + title;}
      //
      if (coords[8] == 'Item'){
        var markicon = this.iconItem
      } else if (coords[8] == 'Mob') {
        var markicon = this.iconMob
      } else if (coords[8] == 'Poi') {
        var markicon = this.iconPoi
      }
      //
      var marker = new GMarker(new GLatLng(y2lat(ucords[1]), ucords[0]), {title: title, icon: markicon });
      marker.marker_id = coords[7];
      //register listener on marker
      GEvent.addListener(marker, "click", function() {
        marker.openInfoWindowHtml("<div class=\"listPhotos\">Loading details...</div>");
        //
        queryURL = '/maps/info/'+marker.marker_id;
        GDownloadUrl(queryURL, function(data, responseCode) {
          marker.openInfoWindowHtml(data);
        });
      });
      return marker;
    }
  }
);

//helpers
//get all selected options from a listbox
function getSelected(el) {
  var Ary = {};
  var I = 0;
  element = $(el);
  options = $A(element.options);
  options.each(function(option){
    if (option.selected) {
      Ary['delete['+I+']'] = option.value;
      I++;
    }
  })
  return Ary;
}

function getSelectedMarkers(el) {
  Ary = getSelected(el);
  Ary['markable_type'] = $F('markable_type');
  Ary['markable_id'] = $F('markable_id');
  //
  return Hash.toQueryString(Ary);
}