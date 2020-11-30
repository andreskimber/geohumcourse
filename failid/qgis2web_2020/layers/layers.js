var wms_layers = [];


        var lyr_StamenWatercolor_0 = new ol.layer.Tile({
            'title': 'Stamen Watercolor',
            'type': 'base',
            'opacity': 1.000000,
            
            
            source: new ol.source.XYZ({
    attributions: ' &middot; <a href="http://maps.stamen.com/">Map tiles by Stamen Design, under CC BY 3.0. Data by OpenStreetMap, under CC BY SA</a>',
                url: 'http://tile.stamen.com/watercolor/{z}/{x}/{y}.jpg'
            })
        });
var lyr_OUTPUT_1 = new ol.layer.Image({
                            opacity: 1,
                            title: "OUTPUT",
                            
                            
                            source: new ol.source.ImageStatic({
                               url: "./layers/OUTPUT_1.png",
    attributions: ' ',
                                projection: 'EPSG:3857',
                                alwaysInRange: true,
                                imageExtent: [2411742.103883, 7858384.980956, 3144829.836013, 8364816.065527]
                            })
                        });
var format_30_ei_ole_2 = new ol.format.GeoJSON();
var features_30_ei_ole_2 = format_30_ei_ole_2.readFeatures(json_30_ei_ole_2, 
            {dataProjection: 'EPSG:4326', featureProjection: 'EPSG:3857'});
var jsonSource_30_ei_ole_2 = new ol.source.Vector({
    attributions: ' ',
});
jsonSource_30_ei_ole_2.addFeatures(features_30_ei_ole_2);
var lyr_30_ei_ole_2 = new ol.layer.Vector({
                declutter: true,
                source:jsonSource_30_ei_ole_2, 
                style: style_30_ei_ole_2,
                interactive: true,
    title: '30_ei_ole<br />\
    <img src="styles/legend/30_ei_ole_2_0.png" /> ei ole<br />\
    <img src="styles/legend/30_ei_ole_2_1.png" /> pole<br />\
    <img src="styles/legend/30_ei_ole_2_2.png" /> <br />'
        });

lyr_StamenWatercolor_0.setVisible(true);lyr_OUTPUT_1.setVisible(true);lyr_30_ei_ole_2.setVisible(true);
var layersList = [lyr_StamenWatercolor_0,lyr_OUTPUT_1,lyr_30_ei_ole_2];
lyr_30_ei_ole_2.set('fieldAliases', {'ANIMI': 'ANIMI', 'AKOOD': 'AKOOD', 'TYYP': 'TYYP', 'ONIMI': 'ONIMI', 'OKOOD': 'OKOOD', 'MNIMI': 'MNIMI', 'MKOOD': 'MKOOD', 'SaKhkLyh': 'SaKhkLyh', 'SaKhk': 'SaKhk', 'SaKylaNr': 'SaKylaNr', 'SaKyla': 'SaKyla', 'SaKJEes': 'SaKJEes', 'SaKJPrk': 'SaKJPrk', 'SaKJSynd': 'SaKJSynd', 'Keelend': 'Keelend', 'SaKom': 'SaKom', 'Keelend2': 'Keelend2', });
lyr_30_ei_ole_2.set('fieldImages', {'ANIMI': 'TextEdit', 'AKOOD': 'TextEdit', 'TYYP': 'TextEdit', 'ONIMI': 'TextEdit', 'OKOOD': 'TextEdit', 'MNIMI': 'TextEdit', 'MKOOD': 'TextEdit', 'SaKhkLyh': 'TextEdit', 'SaKhk': 'TextEdit', 'SaKylaNr': 'TextEdit', 'SaKyla': 'TextEdit', 'SaKJEes': 'TextEdit', 'SaKJPrk': 'TextEdit', 'SaKJSynd': 'TextEdit', 'Keelend': 'TextEdit', 'SaKom': 'TextEdit', 'Keelend2': 'TextEdit', });
lyr_30_ei_ole_2.set('fieldLabels', {'ANIMI': 'no label', 'AKOOD': 'no label', 'TYYP': 'no label', 'ONIMI': 'no label', 'OKOOD': 'no label', 'MNIMI': 'no label', 'MKOOD': 'no label', 'SaKhkLyh': 'no label', 'SaKhk': 'no label', 'SaKylaNr': 'no label', 'SaKyla': 'no label', 'SaKJEes': 'no label', 'SaKJPrk': 'no label', 'SaKJSynd': 'no label', 'Keelend': 'no label', 'SaKom': 'no label', 'Keelend2': 'no label', });
lyr_30_ei_ole_2.on('precompose', function(evt) {
    evt.context.globalCompositeOperation = 'normal';
});