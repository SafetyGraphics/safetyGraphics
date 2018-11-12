HTMLWidgets.widget({

  name: "eDISH",

  type: "output",

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(rSettings) {
        el.innerHTML = "<div class='edish'></div>";
        
        let settings = rSettings.settings;
        settings.max_width = 600;
        rSettings.data = HTMLWidgets.dataframeToD3(rSettings.data);

        // console.log(settings);
         console.log(rSettings);

        safetyedish(".edish", settings).init(rSettings.data);

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
