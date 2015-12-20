loadRelative("dark.scd");


//simple system example
//parameters freq, numHarm, amp;
(
Ndef(\x, { |freq = 99, numHarm = 20, amp = 0.1|
	(Blip.ar(freq, numHarm) !2 ) * amp
	}).play;
)

//parameters  freq   numHarm   amp

//2 class classification, classes A and B
Ndef(\x).set(\freq, rrand(0,100).postln, \numHarm, rrand(0,100).post);


~saveSetting.(Ndef(\x), \A);  //save in class A
~saveSetting.(Ndef(\x), \B);  //save in class B


Ndef(\x).stop



// rule extraction process
(
~mappedSettings = ~mapSettings.(~allSettings);
~rules = ~compress.value(~mappedSettings.all_indices, ~mappedSettings.all_classes);

~getRule = { |permutation, classifier, which ... args|
	var classifierIndex = ~mappedSettings.all_values.at(\classifier).indexOf(classifier);
	var keyIndex = ~mappedSettings.all_keys.indexOf(\classifier);
	var rules = ~rules.wrapAt(permutation);
	var existing = rules.select {|x| x.at(keyIndex) == classifierIndex };
	var rule, j = 0;

	"% rules for %\n".postf(existing.size, classifier);
	rule = existing.wrapAt(which);
	rule.collect { |x, i|
		if(x == -1) {
			x = args.at(0) ? -1;
			args = args.drop(1);
		};
		x
	}
};
);



~rules

//get rule (permutation, classifier, which)
~getRule.(0, \A, 0);
~getRule.(0, \B, 0);




//remap the class values into argument values
~rule = ~getRule.(0, \A, 5);//rule for remapping
~rule.pop;//eliminate the rule classifier for remapping
~rule

Ndef(\x).play;
//mapping the indexes
~mapIndices.(~rule, x)
//set parameter values into Ndef
Ndef(\x).set(*~mapIndices.(~rule, x));

//check the setting values
Ndef(\x).get(\amp)
Ndef(\x).get(\numHarm)
Ndef(\x).get(\freq)


Ndef(\x).stop


// reset
~initSettings.();

