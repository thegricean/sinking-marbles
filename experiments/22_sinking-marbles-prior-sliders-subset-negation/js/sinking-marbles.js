function make_slides(f) {
  var   slides = {};

  slides.i0 = slide({
     name : "i0",
     start: function() {
      exp.startT = Date.now();
     }
  });

  slides.instructions = slide({
    name : "instructions",
    button : function() {
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.cause_effect_prior = slide({
    name : "cause_effect_prior",
    present : exp.all_stims,
    start : function() {
      $(".err").hide();
    },
    present_handle : function(stim) {
      $(".err").hide();    	
      $("#slider_table").empty();
      this.trial_start = Date.now();
      $("#number_guess").html("?");
      this.stim = stim;
      console.log(stim.cause);
      
      if (exp.effecttype == "negated")
      { 
      	effect = stim.negeffect;
      } else {
      	effect = stim.effect;      	
      }
      	
      stim.N = 15;
      if (stim.end_cause.length > 0) {
        var cause = stim.name + " " + stim.beginning_cause + " " + stim.N.toString() + " " + stim.object + " " + stim.end_cause + ".";
      } else {
        var cause = stim.name + " " + stim.beginning_cause + " " + stim.N.toString() + " " + stim.object + ".";
      }
      var effect_question = "How many of the " + stim.object + " " + effect + "?";

      $(".other_name").html(stim.other_name);
      var N = stim.N;
      
		var order = "";
		if (exp.order == "increasing") {
			order = '<tr><td></td><td class="left"><h3>impossible</h3></td><td class="right"><h3>certain</h3></td></tr><tr><td id="0">{{0}}</td><td colspan="2"><div class="slider" id="slider_0"></div></td></tr><tr><td id="1">{{1}}</td><td colspan="2"><div class="slider" id="slider_1"></div></td></tr><tr><td id="2">{{2}}</td><td colspan="2"><div class="slider" id="slider_2"></div></td></tr><tr><td id="3">{{3}}</td><td colspan="2"><div class="slider" id="slider_3"></div></td></tr><tr><td id="4">{{4}}</td><td colspan="2"><div class="slider" id="slider_4"></div></td></tr><tr><td id="5">{{5}}</td><td colspan="2"><div class="slider" id="slider_5"></div></td></tr><tr><td id="6">{{6}}</td><td colspan="2"><div class="slider" id="slider_6"></div></td></tr><tr><td id="7">{{7}}</td><td colspan="2"><div class="slider" id="slider_7"></div></td></tr><tr><td id="8">{{8}}</td><td colspan="2"><div class="slider" id="slider_8"></div></td></tr><tr><td id="9">{{9}}</td><td colspan="2"><div class="slider" id="slider_9"></div></td></tr><tr><td id="10">{{10}}</td><td colspan="2"><div class="slider" id="slider_10"></div></td></tr><tr><td id="11">{{11}}</td><td colspan="2"><div class="slider" id="slider_11"></div></td></tr><tr><td id="12">{{12}}</td><td colspan="2"><div class="slider" id="slider_12"></div></td></tr><tr><td id="13">{{13}}</td><td colspan="2"><div class="slider" id="slider_13"></div></td></tr><tr><td id="14">{{14}}</td><td colspan="2"><div class="slider" id="slider_14"></div></td></tr><tr><td id="15">{{15}}</td><td colspan="2"><div class="slider" id="slider_15"></div></td></tr><tr><td></td><td class="left"><h3>impossible</h3></td><td class="right"><h3>certain</h3></td></tr>';
		} else { 
      		order = '<tr><td></td><td class="left"><h3>impossible</h3></td><td class="right"><h3>certain</h3></td></tr><tr><td id="15">{{15}}</td><td colspan="2"><div class="slider" id="slider_15"></div></td></tr><tr><td id="14">{{14}}</td><td colspan="2"><div class="slider" id="slider_14"></div></td></tr><tr><td id="13">{{13}}</td><td colspan="2"><div class="slider" id="slider_13"></div></td></tr><tr><td id="12">{{12}}</td><td colspan="2"><div class="slider" id="slider_12"></div></td></tr><tr><td id="11">{{11}}</td><td colspan="2"><div class="slider" id="slider_11"></div></td></tr><tr><td id="10">{{10}}</td><td colspan="2"><div class="slider" id="slider_10"></div></td></tr><tr><td id="9">{{9}}</td><td colspan="2"><div class="slider" id="slider_9"></div></td></tr><tr><td id="8">{{8}}</td><td colspan="2"><div class="slider" id="slider_8"></div></td></tr><tr><td id="7">{{7}}</td><td colspan="2"><div class="slider" id="slider_7"></div></td></tr><tr><td id="6">{{6}}</td><td colspan="2"><div class="slider" id="slider_6"></div></td></tr><tr><td id="5">{{5}}</td><td colspan="2"><div class="slider" id="slider_5"></div></td></tr><tr><td id="4">{{4}}</td><td colspan="2"><div class="slider" id="slider_4"></div></td></tr><tr><td id="3">{{3}}</td><td colspan="2"><div class="slider" id="slider_3"></div></td></tr><tr><td id="2">{{2}}</td><td colspan="2"><div class="slider" id="slider_2"></div></td></tr><tr><td id="1">{{1}}</td><td colspan="2"><div class="slider" id="slider_1"></div></td></tr><tr><td id="0">{{0}}</td><td colspan="2"><div class="slider" id="slider_0"></div></td></tr><tr><td></td><td class="left"><h3>impossible</h3></td><td class="right"><h3>certain</h3></td></tr>';
		}

	  $("#slider_table").append(order);
	  this.init_sliders();		   
      exp.sliderPost = {};	     
	  
      $("#0").html("exactly 0"  + " " + stim.object + " " + effect);
      $("#1").html("exactly 1"  + " " + stim.object_sg + " " + effect);      
      $("#2").html("exactly 2"  + " " + stim.object + " " + effect);
      $("#3").html("exactly 3"  + " " + stim.object + " " + effect);      
      $("#4").html("exactly 4"  + " " + stim.object + " " + effect);
      $("#5").html("exactly 5"  + " " + stim.object + " " + effect);      
      $("#6").html("exactly 6"  + " " + stim.object + " " + effect);
      $("#7").html("exactly 7"  + " " + stim.object + " " + effect);      
      $("#8").html("exactly 8"  + " " + stim.object + " " + effect);
      $("#9").html("exactly 9"  + " " + stim.object + " " + effect);      
      $("#10").html("exactly 10"  + " " + stim.object + " " + effect);
      $("#11").html("exactly 11"  + " " + stim.object + " " + effect);      
      $("#12").html("exactly 12"  + " " + stim.object + " " + effect);
      $("#13").html("exactly 13"  + " " + stim.object + " " + effect);      
      $("#14").html("exactly 14"  + " " + stim.object + " " + effect);
      $("#15").html("exactly 15"  + " " + stim.object + " " + effect);       

      $("#cause").html(cause);
      $("#effect_question").html(effect_question);
      this.stim.actual_cause = cause;
      this.stim.actual_effect_question = effect_question;
//      this.stim.actual_utterance = utterance;      
    },
    button : function() {
      var ok_to_go_on = true;
      var slider_ids = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"];
      for (var i=0; i<slider_ids.length; i++) {
        var slider_id = slider_ids[i];
        if (exp.sliderPost[slider_id] == undefined) {
          ok_to_go_on = false;
        }
      }
      if (ok_to_go_on) {
        this.log_responses();
        _stream.apply(this); //use exp.go() if and only if there is no "present" data.
      } else {
        $(".err").show();
      }
    },
    init_sliders : function() {
      var slider_ids = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"];
      for (var i=0; i<slider_ids.length; i++) {
        var slider_id = slider_ids[i];
        utils.make_slider("#slider_" + slider_id,
          function(which_slider_id_is_this) {
            return function(event, ui) {
              exp.sliderPost[which_slider_id_is_this] = ui.value;
            };
          }(slider_id) //wraps up index variable slider_id
        )
      }
    },
    log_responses : function() {
      var slider_ids = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"];
      for (var i=0; i<slider_ids.length; i++) {
        var slider_id = slider_ids[i];
        exp.data_trials.push({
          "trial_type" : "cause_effect_prior",
          "slide_number_in_experiment" : exp.phase,
          "object": this.stim.object,
          "cause": this.stim.cause,
          "num_objects": this.stim.N,
          "effect": this.stim.effect,
          "name": this.stim.name,
          "gender" : this.stim.gender,
          "other_gender" : this.stim.other_gender,
          "actual_cause": this.stim.actual_cause,
          "actual_effect_question": this.stim.actual_effect_question,
          "response" : exp.sliderPost[slider_id],
          "slider_id" : slider_id,
          "rt" : Date.now() - this.trial_start,
          "order" : exp.order,
          "effecttype": exp.effecttype
        });
      }
    }
  });

  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        language : $("#language").val(),
        enjoyment : $("#enjoyment").val(),
        asses : $('input[name="assess"]:checked').val(),
        age : $("#age").val(),
        gender : $("#gender").val(),
        education : $("#education").val(),
        comments : $("#comments").val(),
      };
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.thanks = slide({
    name : "thanks",
    start : function() {
      exp.data= {
          "trials" : exp.data_trials,
          "catch_trials" : exp.catch_trials,
          "system" : exp.system,
          "condition" : exp.condition,
          "subject_information" : exp.subj_data,
          "time_in_minutes" : (Date.now() - exp.startT)/60000
      };
      setTimeout(function() {turk.submit(exp.data);}, 1000);
    }
  });

  return slides;
}

/// init ///
function init() {

  var items = _.shuffle([
    {
      "object":"ice cubes",
      "object_sg":"ice cube",      
      "cause":"left __ in the hot sun",
      "effect":"melted",
      "negeffect": "didn't melt",
      "extrautt":"It's a beautiful day."
    },
    {
      "object":"baseballs",
      "object_sg":"baseball",
      "cause":"threw __ against a wall",
      "effect":"stuck to the wall",
      "negeffect": "didn't stick to the wall",      
      "extrautt":"What a strange thing to do."      
    },
    {
      "object":"napkins",
      "object_sg":"napkin",      
      "cause":"left __ on a table on a windy day",
      "effect":"blew away",
      "negeffect": "didn't blow away",      
      "extrautt":"I just wish the weather was better."      
    },
    {
      "object":"shirts",
      "object_sg":"shirt",
      "cause":"used __ as dog toys",
      "effect":"ripped",
      "negeffect": "didn't rip",      
      "extrautt":"Doesn't the dog have its own toys?"      
    },
    {
      "object":"sugar cubes",
      "object_sg":"sugar cube",      
      "cause":"put __ in a bucket of water",
      "effect":"dissolved",
      "negeffect": "didn't dissolve",      
      "extrautt":"There are people starving in the world."      
    },
    {
      "object":"birds",
      "object_sg":"bird",      
      "cause":"left seeds out for __",
      "effect":"ate the seeds",
      "negeffect": "didn't eat the seeds",      
      "extrautt":"I wish someone would leave seeds out for me."      
    },
    {
      "object":"marbles",
      "object_sg":"marble",      
      "cause":"threw __ into a pool",
      "effect":"sank",
      "negeffect": "didn't sink",      
      "extrautt":"It's just fun to throw stuff in the water."      
    },
    {
      "object":"shelves",
      "object_sg":"shelf",
      "cause":"punched __",
      "effect":"fell down",
      "negeffect": "didn't fall down",      
      "extrautt":"Some people just love destruction."      
    }
  ]);

  var names = _.shuffle([
    {
      "name":"James",
      "gender":"M"
    },
    {
      "name":"John",
      "gender":"M"
    },
    {
      "name":"Robert",
      "gender":"M"
    },
    {
      "name":"Michael",
      "gender":"M"
    },
    {
      "name":"William",
      "gender":"M"
    },
    {
      "name":"David",
      "gender":"M"
    },
    {
      "name":"Richard",
      "gender":"M"
    },
    {
      "name":"Joseph",
      "gender":"M"
    },
    {
      "name":"Charles",
      "gender":"M"
    },
    {
      "name":"Thomas",
      "gender":"M"
    },
    {
      "name":"Christopher",
      "gender":"M"
    },
    {
      "name":"Daniel",
      "gender":"M"
    },
    {
      "name":"Matthew",
      "gender":"M"
    },
    {
      "name":"Donald",
      "gender":"M"
    },
    {
      "name":"Anthony",
      "gender":"M"
    },
    {
      "name":"Paul",
      "gender":"M"
    },
    {
      "name":"Mark",
      "gender":"M"
    },
    {
      "name":"George",
      "gender":"M"
    },
    {
      "name":"Steven",
      "gender":"M"
    },
    {
      "name":"Kenneth",
      "gender":"M"
    },
    {
      "name":"Andrew",
      "gender":"M"
    },
    {
      "name":"Edward",
      "gender":"M"
    },
    {
      "name":"Joshua",
      "gender":"M"
    },
    {
      "name":"Brian",
      "gender":"M"
    },
    {
      "name":"Kevin",
      "gender":"M"
    },
    {
      "name":"Ronald",
      "gender":"M"
    },
    {
      "name":"Timothy",
      "gender":"M"
    },
    {
      "name":"Jason",
      "gender":"M"
    },
    {
      "name":"Jeffrey",
      "gender":"M"
    },
    {
      "name":"Gary",
      "gender":"M"
    },
    {
      "name":"Ryan",
      "gender":"M"
    },
    {
      "name":"Nicholas",
      "gender":"M"
    },
    {
      "name":"Eric",
      "gender":"M"
    },
    {
      "name":"Jacob",
      "gender":"M"
    },
    {
      "name":"Jonathan",
      "gender":"M"
    },
    {
      "name":"Larry",
      "gender":"M"
    },
    {
      "name":"Frank",
      "gender":"M"
    },
    {
      "name":"Scott",
      "gender":"M"
    },
    {
      "name":"Justin",
      "gender":"M"
    },
    {
      "name":"Brandon",
      "gender":"M"
    },
    {
      "name":"Raymond",
      "gender":"M"
    },
    {
      "name":"Gregory",
      "gender":"M"
    },
    {
      "name":"Samuel",
      "gender":"M"
    },
    {
      "name":"Benjamin",
      "gender":"M"
    },
    {
      "name":"Patrick",
      "gender":"M"
    },
    {
      "name":"Jack",
      "gender":"M"
    },
    {
      "name":"Dennis",
      "gender":"M"
    },
    {
      "name":"Jerry",
      "gender":"M"
    },
    {
      "name":"Alexander",
      "gender":"M"
    },
    {
      "name":"Tyler",
      "gender":"M"
    },
    {
      "name":"Mary",
      "gender":"F"
    },
    {
      "name":"Jennifer",
      "gender":"F"
    },
    {
      "name":"Elizabeth",
      "gender":"F"
    },
    {
      "name":"Linda",
      "gender":"F"
    },
    {
      "name":"Emily",
      "gender":"F"
    },
    {
      "name":"Susan",
      "gender":"F"
    },
    {
      "name":"Margaret",
      "gender":"F"
    },
    {
      "name":"Jessica",
      "gender":"F"
    },
    {
      "name":"Dorothy",
      "gender":"F"
    },
    {
      "name":"Sarah",
      "gender":"F"
    },
    {
      "name":"Karen",
      "gender":"F"
    },
    {
      "name":"Nancy",
      "gender":"F"
    },
    {
      "name":"Betty",
      "gender":"F"
    },
    {
      "name":"Lisa",
      "gender":"F"
    },
    {
      "name":"Sandra",
      "gender":"F"
    },
    {
      "name":"Helen",
      "gender":"F"
    },
    {
      "name":"Ashley",
      "gender":"F"
    },
    {
      "name":"Donna",
      "gender":"F"
    },
    {
      "name":"Kimberly",
      "gender":"F"
    },
    {
      "name":"Carol",
      "gender":"F"
    },
    {
      "name":"Michelle",
      "gender":"F"
    },
    {
      "name":"Emily",
      "gender":"F"
    },
    {
      "name":"Amanda",
      "gender":"F"
    },
    {
      "name":"Melissa",
      "gender":"F"
    },
    {
      "name":"Deborah",
      "gender":"F"
    },
    {
      "name":"Laura",
      "gender":"F"
    },
    {
      "name":"Stephanie",
      "gender":"F"
    },
    {
      "name":"Rebecca",
      "gender":"F"
    },
    {
      "name":"Sharon",
      "gender":"F"
    },
    {
      "name":"Cynthia",
      "gender":"F"
    },
    {
      "name":"Kathleen",
      "gender":"F"
    },
    {
      "name":"Ruth",
      "gender":"F"
    },
    {
      "name":"Anna",
      "gender":"F"
    },
    {
      "name":"Shirley",
      "gender":"F"
    },
    {
      "name":"Amy",
      "gender":"F"
    },
    {
      "name":"Angela",
      "gender":"F"
    },
    {
      "name":"Virginia",
      "gender":"F"
    },
    {
      "name":"Brenda",
      "gender":"F"
    },
    {
      "name":"Catherine",
      "gender":"F"
    },
    {
      "name":"Nicole",
      "gender":"F"
    },
    {
      "name":"Christina",
      "gender":"F"
    },
    {
      "name":"Janet",
      "gender":"F"
    },
    {
      "name":"Samantha",
      "gender":"F"
    },
    {
      "name":"Carolyn",
      "gender":"F"
    },
    {
      "name":"Rachel",
      "gender":"F"
    },
    {
      "name":"Heather",
      "gender":"F"
    },
    {
      "name":"Diane",
      "gender":"F"
    },
    {
      "name":"Joyce",
      "gender":"F"
    },
    {
      "name":"Julie",
      "gender":"F"
    },
    {
      "name":"Emma",
      "gender":"F"
    }
  ]);

  
//  var Ns = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
	var Ns = [15];

  function makeStim(i) {
    //get item
    var item = items[i];
    //get name
    var name_data = names[i];
    var name = name_data.name;
    var gender = name_data.gender;

    //make sure we have double as many names as trials!
    var other_name_data = names[names.length - i - 1];
    var other_name = other_name_data.name;
    var other_gender = other_name_data.gender;

    //get level
    var object_level = "object";//_.shuffle(["object_low", "object_mid", "object_high"])[0];
    //get pronouns
    var nom = gender == "M" ? "he" : "she";
    var acc = gender == "M" ? "him" : "her";
    var gen = gender == "M" ? "his" : "her";
    //get cause and effect elements
    var cause = item.cause;
    var effect = item.effect;
    var negeffect = item.negeffect;    
    var object = item[object_level];
    var object_sg = item[object_level+"_sg"];    
    var cause_elements = cause.split("__");
    var beginning_cause = cause_elements[0];
    var end_cause = cause_elements.length > 1 ? cause_elements[1] : "";
    return {
      "name": name,
      "gender": gender,
      "other_name": other_name,
      "other_gender": other_gender,
      "cause": cause,
      "effect": effect,
      "negeffect": negeffect,      
      "object": object,
      "object_sg": object_sg,
      "beginning_cause": beginning_cause,
      "end_cause": end_cause
    }
  }
  exp.all_stims = [];
  for (var i=0; i<items.length; i++) {
    exp.all_stims.push(makeStim(i));
  }

  exp.order = _.shuffle(["increasing","decreasing"])[0];
  exp.effecttype = _.shuffle(["normal","negated"])[0];  
  exp.trials = [];
  exp.catch_trials = [];
  exp.condition = {}; //can randomize between subject conditions here
  exp.system = {
      Browser : BrowserDetect.browser,
      OS : BrowserDetect.OS,
      screenH: screen.height,
      screenUH: exp.height,
      screenW: screen.width,
      screenUW: exp.width
    };
  //blocks of the experiment:
  exp.structure=["i0", "instructions", "cause_effect_prior", 'subj_info', 'thanks'];
  
  exp.data_trials = [];
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
                    //relies on structure and slides being defined
  $(".nQs").html(exp.nQs);

  $('.slide').hide(); //hide everything

  //make sure turkers have accepted HIT (or you're not in mturk)
  $("#start_button").click(function() {
    if (turk.previewMode) {
      $("#mustaccept").show();
    } else {
      $("#start_button").click(function() {$("#mustaccept").show();});
      exp.go();
    }
  });

  exp.go(); //show first slide
}