HTMLWidgets.widget({

  name: "safetyoutlierexplorer",

  type: "output",

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(rSettings) {
        el.innerHTML = "<div class='safetyoutlierexplorer-wrapper'></div>";
        var settings = rSettings.settings;

        if(settings.debug_js){
         console.log("R settings:")
         console.log(rSettings);
        }
        console.log(rSettings);

        settings.max_width = 1000;
        rSettings.data = HTMLWidgets.dataframeToD3(rSettings.data);
        safetyOutlierExplorer(".safetyoutlierexplorer-wrapper", settings).init(rSettings.data);
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
