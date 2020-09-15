HTMLWidgets.widget({
  name: "hepexplorer",
  type: "output",

  factory: function(el, width, height) {

    return {
      renderValue: function(rSettings) {
        console.log(rSettings)
        let settings = rSettings.settings;
        let data = HTMLWidgets.dataframeToD3(rSettings.data);
        var chart = hepexplorer("#"+rSettings.ns, settings)
        chart.init(data);
      },
      resize: function(width, height) {
        // TODO: code to re-render the widget with a new size
      }

    };
  }
});
