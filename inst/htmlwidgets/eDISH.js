HTMLWidgets.widget({

  name: "eDISH",

  type: "output",

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(rSettings) {
        el.innerHTML = "<div class='edish'></div>";

        var settings = {
            "value_col": "AVAL",
            "measure_col": "PARAM",
            "visitn_col": "VISITNUM",
            "studyday_col": "ADY",
            "normal_col_low": "A1LO",
            "normal_col_high": "A1HI",
            "id_col": "USUBJID",
            "group_cols": ["TRTA","RACE","AGEGR1"],
            "measure_values":{
              "ALT":"Alanine Aminotransferase (U/L)",
              "AST":"Aspartate Aminotransferase (U/L)",
              "TB":"Bilirubin (umol/L)",
              "ALP":"Alkaline Phosphatase (U/L)"
            }
        };

         rSettings.data = HTMLWidgets.dataframeToD3(rSettings.data);

         console.log(settings);
         console.log(rSettings);

        safetyedish(".edish", settings).init(rSettings.data);

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
