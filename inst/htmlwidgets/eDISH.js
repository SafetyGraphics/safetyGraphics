HTMLWidgets.widget({

  name: 'eDISH',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(rSettings) {


        el.innerHTML = "<div class='edish'></div>";

        let settings = rSettings.settings;
        settings.max_width = 600;
        
       // let settings = {
        //    max_width: 600,
           // value_col: 'AVAL',
           // measure_col: 'PARAM',
           // visitn_col: 'VISITNUM',
           //studyday_col: 'ADY',
           //normal_col_low: 'A1LO',
           // normal_col_high: 'A1HI',
           // id_col: 'USUBJID',
           // group_cols: ['TRTA','RACE','AGEGR1'],
           // filters: [
           //     {
           //         value_col: 'TRTA',
          //          label: 'Treatment'
          //     },
          //      {
          //          value_col: 'SEX',
         //           label: 'Sex'
         //       },
         //       {
         //           value_col: 'RACE',
         //           label: 'Race'
         //       },
         //       {
         //           value_col: 'AGEGR1',
         //           label: 'Age group'
        //        },
        //    ],
       //              //   measure_values:{
        //     'ALT':'Alanine Aminotransferase (U/L)',
        //      'AST':'Aspartate Aminotransferase (U/L)',
        //     'TB':'Bilirubin (umol/L)',
        //    'ALP':'Alkaline Phosphatase (U/L)'
        //   }
       //     value_col: rSettings.settings.value_col,
       //     measure_col: rSettings.settings.measure_col,
         //   visitn_col: rSettings.settings.visitn_col,
           // normal_col_low: rSettings.settings.normal_col_low,
      //      normal_col_high: rSettings.settings.normal_col_high,
      //      id_col: rSettings.settings.id_col,
      //      baseline_visitn: rSettings.settings.baseline_visitn,
      //      filters: rSettings.settings.filters,
      //      group_cols: rSettings.settings.group_cols,
      //      measure_values: rSettings.settings.measure_values,
      //      x_options: rSettings.settings.x_options,
      //      y_options: rSettings.settings.y_options,
      //      measure_bounds: rSettings.settings.measure_bounds,
      //      visit_window: rSettings.settings.visit_window,
      //      r_ratio_filter: rSettings.settings.r_ratio_filter,
      //      r_ratio_cut: rSettings.settings.r_ratio_cut,
      //      showTitle: rSettings.settings.showTitle,
      //      warningText: rSettings.settings.warningText
      //  };
        
         rSettings.data = HTMLWidgets.dataframeToD3(rSettings.data);


         console.log(settings);
         console.log(rSettings);
         
        safetyedish('.edish', settings).init(rSettings.data);

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});