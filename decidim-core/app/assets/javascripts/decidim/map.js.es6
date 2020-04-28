// = require leaflet
// = require leaflet-tilelayer-here
// = require leaflet-svg-icon
// = require leaflet.markercluster
// = require jquery-tmpl
// = require_self

// = require data/mel_communes.geojson

L.DivIcon.SVGIcon.DecidimIcon = L.DivIcon.SVGIcon.extend({
  options: {
    fillColor: "#ff1515",
    opacity: 0
  },
  _createPathDescription: function() {
    return "M14 1.17a11.685 11.685 0 0 0-11.685 11.685c0 11.25 10.23 20.61 10.665 21a1.5 1.5 0 0 0 2.025 0c0.435-.435 10.665-9.81 10.665-21A11.685 11.685 0 0 0 14 1.17Zm0 17.415A5.085 5.085 0 1 1 19.085 13.5 5.085 5.085 0 0 1 14 18.585Z";
  },
  _createCircle: function() {
    return ""
  }
});

const popupTemplateId = "marker-popup";
$.template(popupTemplateId, $(`#${popupTemplateId}`).html());

const updateCoordinates = (data) => {
  $('input[data-type="latitude"]').val(data.lat)
  $('input[data-type="longitude"]').val(data.lng)
}

const addMarkers = (markersData, markerClusters, map) => {
  // const bounds = new L.LatLngBounds(markersData.map((markerData) => [markerData.latitude, markerData.longitude]));

  markersData.forEach((markerData) => {
    let marker = L.marker([markerData.latitude, markerData.longitude], {
      icon: new L.DivIcon.SVGIcon.DecidimIcon(),
      draggable: markerData.draggable
    });

    if (markerData.draggable)  {
      updateCoordinates({
        lat: markerData.latitude,
        lng: markerData.longitude
      });
      marker.on("drag", (ev) => {
        updateCoordinates(ev.target.getLatLng());
      });
    } else {
      let node = document.createElement("div");
      $.tmpl(popupTemplateId, markerData).appendTo(node);
      marker.bindPopup(node, {
        maxwidth: 640,
        minWidth: 500,
        keepInView: true,
        className: "map-info"
      }).openPopup();
    }

    markerClusters.addLayer(marker);
  });

  map.addLayer(markerClusters);
};

const loadMap = (mapId, markersData) => {
  let markerClusters = L.markerClusterGroup();
  const { hereApiKey } = window.Decidim.mapConfiguration;

  if (window.Decidim.currentMap) {
    window.Decidim.currentMap.remove();
    window.Decidim.currentMap = null;
  }

  const map = L.map(mapId);

  L.tileLayer.here({
    apiKey: hereApiKey
  }).addTo(map);

  const geojsonLayer = L.geoJSON(window.Decidim.geojson, {
    style: function () {
      return {
        color: "#ff1515",
        weight: 1,
        fillOpacity: 0.05
      };
    }
  }).addTo(map);

  if (markersData.length > 0) {
    addMarkers(markersData, markerClusters, map);
    if (markersData.length === 1) {
      map.fitBounds(markerClusters.getBounds(), { padding: [100, 100] });
    } else {
      map.fitBounds(markerClusters.getBounds(), { padding: [10, 10] });
    }
  } else {
    map.fitBounds(geojsonLayer.getBounds());
  }


  map.scrollWheelZoom.disable();

  return map;
};

window.Decidim = window.Decidim || {};

window.Decidim.loadMap = loadMap;
window.Decidim.updateCoordinates = updateCoordinates;
window.Decidim.currentMap =  null;
window.Decidim.mapConfiguration = {};

$(() => {
  const mapId = "map";
  const $map = $(`#${mapId}`);

  const markersData = $map.data("markers-data");
  const hereApiKey = $map.data("here-api-key");

  window.Decidim.mapConfiguration = { hereApiKey };

  if ($map.length > 0) {
    window.Decidim.currentMap = loadMap(mapId, markersData);
  }

  $("#address_input_modal").on("open.zf.reveal", () => {
    setTimeout(() => {
      window.Decidim.currentMap.invalidateSize();
    }, 10);
  })
});
