HTMLWidgets.widget({

  name: "eDISH",

  type: "output",

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(rSettings) {
        el.innerHTML = "<div class='edish'></div>";

        var settings = {
            "max_width": 600,
            "value_col": "AVAL",
            "measure_col": "PARAM",
            "visitn_col": "VISITNUM",
            "studyday_col": "ADY",
            "normal_col_low": "A1LO",
            "normal_col_high": "A1HI",
            "id_col": "USUBJID",
            "group_cols": ["TRTA","RACE","AGEGR1"],
            "filters": [
                {
                    "value_col": "TRTA",
                    "label": "Treatment"
                },
                {
                    "value_col": "SEX",
                    "label": "Sex"
                },
                {
                    "value_col": "RACE",
                    "label": "Race"
                },
                {
                    "value_col": "AGEGR1",
                    "label": "Age group"
                }
            ],
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
