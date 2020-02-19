HTMLWidgets.widget({

  name: "chartRenderer",

  type: "output",

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(rSettings) {
        el.innerHTML = "<div class='"+rSettings.chartFunction+"-wrapper'></div>";
        var settings = rSettings.settings;

        if(settings.debug_js){
         console.log("R settings:")
         console.log(rSettings);
        }
      console.log(rSettings);
        rSettings.data = HTMLWidgets.dataframeToD3(rSettings.data);
        if(rSettings.subFunction){
          var chart = window[rSettings.chartFunction][rSettings.subFunction]("." + rSettings.chartFunction + "-wrapper", settings)
        }else{
          var chart = window[rSettings.chartFunction]("." + rSettings.chartFunction + "-wrapper", settings)
        }
        
        chart.init(rSettings.data);
      },

      resize: function(width, height) {
        // TODO: code to re-render the widget with a new size
      }

    };
  }
});
