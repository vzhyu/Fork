(
s.waitForBoot(
	//SYNTHDEFS
	(
		SynthDef(\bass, {
			arg freq, pan = 0, lo = 0.99, hi = 1.01, amp = 0.2, ampLag = 2, sus, out = 0;
			var sig;
			sig = 15.collect({
				LFSaw.ar(freq*rrand(lo, hi), mul:0.05);
			});
			amp = amp.lag(ampLag);
			sig = Splay.ar(sig, LFNoise1.ar(1).range(0.5, 0.9));
			// sig = Pan2.ar(sig, pan);
			sig = MoogFF.ar(sig, LFNoise1.ar(0.2).range(550, 1000));
			sig = sig.scramble;
			sig = sig*amp;
			Out.ar(out, sig);
		}).add;
	);

	(
		SynthDef(\rhythmicBass, {
			arg freq, pan = 0, lo = 0.99, hi = 1.01, amp = 0.2, out = 0;
			var sig, env;
			env = EnvGen.ar(Env.perc(), doneAction:2);
			sig = 15.collect({
				LFSaw.ar(freq*rrand(lo, hi), mul:0.05);
			});
			sig = Splay.ar(sig, center:pan);
			// sig = Pan2.ar(sig, pan);
			sig = MoogFF.ar(sig, LFNoise1.ar(0.2).range(550, 1000));
			sig = sig.scramble;
			sig = sig*env;
			sig = sig*amp;
			Out.ar(out, sig);
		}).add;
	);

	(
		SynthDef(\moveTone, {
			arg freq, pan = 0, noise = 0.1, amp = 0.2, atkTime = 0.01, susTime = 0, relTime = 1, out = 0;
			var sig0, sig1, sig, env;
			env = EnvGen.ar(Env.new([0, 1, 1, 0], [atkTime, susTime, relTime], \sqr), doneAction:2);
			sig0 = 5.collect({
				SinOsc.ar(freq*rrand(1-noise, 1+noise), mul:0.01);
			});
			sig0 = Mix.ar(sig0);
			sig1 = 5.collect({
				LFSaw.ar(freq*rrand(1-noise, 1+noise), mul:0.01);
			});
			sig1 = Mix.ar(sig1);
			sig = Mix.ar([sig0, sig1]);
			sig = sig * env;
			sig = Pan2.ar(sig, pan);
			sig = sig*amp;
			Out.ar(out, sig);
		}).add;
	);

	(
		SynthDef(\queen, {
			arg freq, pan = 0, noise = 0.1, amp = 0.2, oct0, oct1;
			var sig0, sig1, sig, ratios, env;
			env = EnvGen.ar(Env.perc(), doneAction:2);
			ratios = [2, 3/2, 4/3];
			sig0 = 20.collect({
				var part, partRatio, oct;
				partRatio = ratios.choose;
				// oct = 2**rrand(0, -3);
				part = SinOsc.ar(freq*partRatio*oct0*rrand(1-noise, 1+noise), mul:0.01);
			});
			sig0 = Mix.ar(sig0);
			sig1 = 20.collect({
				var part, partRatio, oct;
				partRatio = ratios.choose;
				// oct = 2**rrand(0, -3);
				part = LFSaw.ar(freq*partRatio*oct1*rrand(1-noise, 1+noise), mul:0.01);
			});
			sig1 = Mix.ar(sig1);
			sig = Mix.ar([sig0, sig1]);
			sig = sig*env;
			sig = Pan2.ar(sig, pan);
			sig = sig*amp;
			Out.ar(0, sig);
		}).add;
	);
	(
		SynthDef(\delay, {
			arg in, out = 0, bgTime = 1.5;
			var inSig, dry, wet, sig;
			inSig = In.ar(in, 2);
			dry = inSig;
			wet = CombL.ar(inSig, 0.2, 0.1*bgTime, 5);
			sig = XFade2.ar(dry, wet, 0);
			Out.ar(out, sig);
		}).add;
	);
	(
		SynthDef(\reverb, {
			arg in, out = 0;
			var inSig, dry, wet, sig;
			inSig = In.ar(in, 2);
			dry = inSig;
			wet = FreeVerb.ar(inSig);
			sig = XFade2.ar(dry, wet, 0);
			Out.ar(out, sig);
		}).add;
	);
)
)



//READ FILE
(
~gameRead = TabFileReader.read("/Users/vzhyu/Documents/Compositions/Chess/ding-prag.txt", true);
// ~gameRead = TabFileReader.read("/Users/vzhyu/Documents/Compositions/Chess/chess.2024-10-13.txt", true);
~game = [];
~gameRead.do({
	arg i;
	if (i[0][0] != $#, {
		// i.postln;
		~game = ~game.add(i);
	});
});
)

(
~gameList = ~game.collect({
	arg n, i;
	(
		moveNo: n[0].asInteger,
		side: {
			if (n[1] == "White", {
				0;
			}, {
				1;
			}
			);
		},
		wStr: n[2].asInteger,
		wSco: n[3].asInteger,
		bStr: n[4].asInteger,
		bSco: n[5].asInteger,
		wAtk: n[8].asInteger,
		wAtkSco: n[9].asInteger,
		bAtk: n[10].asInteger,
		bAtkSco: n[11].asInteger,
		wAtkDel: {
			if (i == 0, {
				0;
			}, {
				(~gameList[i].wAtk).asInteger - (~gameList[i-1].wAtk).asInteger;
			}
			);
		},
		bAtkDel: {
			if (i == 0, {
				0;
			}, {
				(~gameList[i].bAtk).asInteger - (~gameList[i-1].bAtk).asInteger;
			}
			);
		},
		wStrDel: {
			if (i == 0, {
				0;
			}, {
				(~gameList[i].wStr).asInteger - (~gameList[i-1].wStr).asInteger;
			}
			);

		},
		bStrDel: {
			if (i == 0, {
				0;
			}, {
				(~gameList[i].bStr).asInteger - (~gameList[i-1].bStr).asInteger;
			}
			);
		},
		wScoDel: {
			if (i == 0, {
				0;
			}, {
				(~gameList[i].wSco).asInteger - (~gameList[i-1].wSco).asInteger;
			}
			);
		},
		bScoDel: {
			if (i == 0, {
				0;
			}, {
				(~gameList[i].bSco).asInteger - (~gameList[i-1].bSco).asInteger;
			}
			);
		},
		wAtkScoDel: {
			if (i == 0, {
				0;
			}, {
				(~gameList[i].wAtkSco).asInteger - (~gameList[i-1].wAtkSco).asInteger;
			}
			);
		},
		bAtkScoDel: {
			if (i == 0, {
				0;
			}, {
				(~gameList[i].bAtkSco).asInteger - (~gameList[i-1].bAtkSco).asInteger;
			}
			);
		},
		capture: {
			if (~gameList[i].wStrDel == 0, {
				if (~gameList[i].bStrDel == 0, {
					false;
				}, {
					~firstCapture = true;
					true;
				}
				);
			},
			{
				~firstCapture = true;
				true;
			}
			);
		},
		totalStr: {
			~gameList[i].wStr + ~gameList[i].bStr;
		},
		check: {
			var check;
			check = false;
			if (~gameList[i].wAtkSco >= 1000, {
				check = true;
				~firstCheck = true;
			});
			if (~gameList[i].bAtkSco >= 1000, {
				check = true;
				~firstCheck = true;
			});
			check;
		},
		checkmate: {
			var checkmate;
			checkmate = false;
			if (~gameList[i].wAtkSco >= 10000, {
				checkmate = true;
				~winner = 0;
			});
			if (~gameList[i].bAtkSco >= 10000, {
				checkmate = true;
				~winner = 1;
			});
			~checkmate = checkmate;
			checkmate;
		},
		resign: {
			var resignation;
			resignation = false;
			if(~gameList[i].wStr == 0, {
				~winner = 1;
				resignation = true;
			});
			if(~gameList[i].bStr == 0, {
				~winner = 0;
				resignation = true;
			});
			~resignation = resignation;
			resignation;
		},
		print: {
			var wAtk, bAtk, wAtkDel, bAtkDel, total, wOutString, bOutString;
			wAtk = ~gameList[i].wAtk;
			bAtk = ~gameList[i].bAtk;
			wAtkDel = ~gameList[i].wAtkDel;
			bAtkDel = ~gameList[i].bAtkDel;
			total = wAtkDel + bAtkDel;
			if(~gameList[i].wStr > 0, {
				if(~gameList[i].bStr > 0, {
					((~gameList[i].moveNo).asString ++ ".").postln;
					wOutString = wAtk.asString ++ " squares under attack by White" ++ " (" ++ wAtkDel ++ " difference)";
					bOutString = bAtk.asString ++ " squares under attack by Black" ++ " (" ++ bAtkDel ++ " difference)";
					wOutString.postln;
					bOutString.postln;
				});
			});
			if (~gameList[i].check == true, {
				if(~gameList[i].checkmate == true, {
					"Checkmate!".postln;
				}, {
					"Check!".postln;
				}
				);
			});
			"----------------------------------------------------------------".postln;
		}

	)

});
~gameStream = Pseq(~gameList).asStream;

)

(
~picPaths = PathName("ding_prag".resolveRelative).entries.collect({ |n|
// ~picPaths = PathName("kasparov_topalov_1999".resolveRelative).entries.collect({ |n|
	n.fullPath;
});
~pics = ~picPaths.collect({
	arg n;
	Image.open(n);
});
~picRender = ~pics.collect({
	arg n, i;
	(
		rend: {
			w.close;
			w = n.plot("chess");
			w.bounds_(Rect(20, 400, 600, 600));
			w.alwaysOnTop_(true);
			// w.canFocus_(false);
			w.asView.keyDownAction_({
				~step.();
			});
		}
	)
});
~picRenderStream = Pseq(~picRender).asStream;
w = Window.new();
)


(
var next;
next = ~gameStream.next;
next.postln;
next.side.postln;
next.wStr.postln;
next.bStr.postln;
next.capture.postln;
next.totalStr.postln;
next.check.postln;
// next.wAtkDel.postln;
// next.bAtkDel.postln;

)


//INITVALS
(
~pow = 2.pow(1/12);
~tonicFreq = 110*~pow.pow(2);
~tonicFreq = 36.midicps;
~tonicMIDI = ~tonicFreq.cpsmidi;


// (
// Pbindef(\bgMelody,
// 	\degree, Pwrand([0, 1, 2, 3, 4], [4, 3, 2, 3, 1].normalizeSum, inf),
// 	\dur, 0.1,
// ).play
// )
~winner = nil;
~checkmate = false;
~resignation = false;
~firstCheck = false;
~firstCapture = false;
~firstRes = false;
~bgNotes = [];
~bgWeights = [];
~accentPattern = [0.2, 0.1, 0.1, 0.1];
~counter = 0;
~stab = 0;
~bassShift = 12;
~bassDeg = 7;
~scale = Scale.dorian;
~scaleDegs = (~scale.degrees-12)++~scale.degrees++(~scale.degrees+12)++(~scale.degrees+24);
~offset = 0;
~counter = 0;
~bgTime = 1.5;
~hmTime = 6;
~bgAmp = 0;
~rbAmp = 0;
~hmAmp = 0;
~hpAmp = 0;
~dpAmp = 0;
~amps = [~bgAmp, ~rbAmp, ~hmAmp];
~bgRhythm = [2, 2, 6];
~hmRhythm = [2, 4, 3];

~bassGroup = Group.new();

~reverbBus = Bus.audio(s, 2);
~delayBus = Bus.audio(s, 2);


~bassWalk = {
	arg dest = 7, len = 3, stepSize = 1;
	var scale, steps;
	// scale.postln;
	steps = len.collect({
		arg i;
		var step;
		step = dest - i;
		step = step+(rrand(stepSize*(-1), stepSize));
		~scaleDegs[step];
	});
	steps = steps.reverse;
	steps = steps ++ ~scaleDegs[dest];
};

~next = {
	// arg i;
	var next, nextFrame, atkDel, scoDel, atkScoDel, deg, emph = false, rookCapt = false, queenCapt = false, end = false, freq, freqArray, bassShift, out = ~reverbBus;
	next = ~gameStream.next;
	nextFrame = ~picRenderStream.next;
	~counter = ~counter + 1;
	out = ~reverbBus;
	freqArray = [];
	if (next == nil, {
		var winner, endString;
		{
			Pbindef(\bgMelody, \amp, Pgeom(0.2*~bgAmp, 0.95, inf));
			Pbindef(\bassRhythm, \amp, Pgeom(0.2*~rbAmp, 0.95, inf));
			10.wait;
			~bgm.stop;
			3.wait;
			~bassGroup.set(\amp, 0, \ampLag, 16);
		}.fork;
		if(~winner == 0, {
			winner = "White";
		});
		if(~winner == 1, {
			winner = "Black";
		});
		if(~checkmate == true, {
			endString = winner ++ " won by checkmate";
			endString.postln;
		});
		if(~resignation == true, {
			endString = winner ++ " won by resignation";
			endString.postln;
		});

	});
	if (next != nil, {
		next.print.();
		atkDel = abs(next.wAtkDel) + abs(next.bAtkDel);
		// atkDel.postln;
		// next.atkScoDel.postln;
		scoDel = abs(next.wScoDel) + abs(next.bScoDel);
		atkScoDel = abs(next.wAtkScoDel) + abs(next.bAtkScoDel);

		if(atkDel == 0, {
			deg = [0, 2, 4].choose;
		});
		if(atkDel == 1, {
			deg = [1, 3].choose;
		});
		if(atkDel >= 2, {
			deg = [-1, 1, 3].choose;
			// emph = true;
		});
		if(scoDel > 3, {
			if(scoDel > 5, {
				deg = [-1, 1, 3].choose;
				queenCapt = true;
				emph = true;
			}, {
				deg = [-1, 1, 3].choose;
				rookCapt = true;
				emph = true;
			}
			);
		});
		if(next.checkmate == true, {
			end = true;
			deg = ~bassDeg;
			emph = false;
			out = ~delayBus;
		});
		if(next.resign == true, {
			end = true;
			deg = ~bassDeg;
			emph = false;
			out = ~delayBus;
		});
		if(end == true, {
			// Pbindef(\bgMelody, \amp, Pgeom(0.2*~bgAmp, 0.95, inf));
			// Pbindef(\bassRhythm, \amp, Pgeom(0.2*~rbAmp, 0.95, inf));
			// // Pbindef(\highMelody).stop;
			// // Pbindef(\highPerc).stop;
			// ~dpAmp = 0.2;
		});
		~bgNotes = ~bgNotes.add(deg);
		if(~bgNotes.size > 10, {
			~bgNotes.removeAt(0);
		});
		freq = ~scale.degreeToFreq(deg, ~tonicFreq, 2);
		freqArray = freqArray.add(freq);
		// Synth(\moveTone, [
		// 	\freq, freq,
		// 	\noise, 0.05,
		// ]);

		if (~counter > 0, {
			~bassLine.set(\amp, 0.7, \ampLag, 4);
			~dpAmp = 0.5;
		});
		if (~counter > 5, {
			~bassLine.set(\amp, 0.4, \ampLag, 8);
			~bgAmp = 1;
			~dpAmp = 0;
		});
		if (~firstCapture == true, {
			~rbAmp = 1;
			Pbindef(\bgMelody, \pan, Pseq(Array.series(20, 0, 0.05)++Array.series(40, 1, -0.05)++Array.series(20, -1, 0.05), inf))
		});
		if (~firstCheck == true, {
			~hmAmp = 1;
		});
		if (~firstRes == true, {
			~hpAmp = 1;
			~hmAmp = 1;
			~bassLineDouble.set(\amp, 0.7, \ampLag, 4);
			Pbindef(\bassRhythm, \pan, Pseq(Array.series(20, 0, 0.05)++Array.series(40, 1, -0.05)++Array.series(20, -1, 0.05), inf))

		});
		if(emph == false, {
			if (~stab >= 3, {
				// ~bassShift = 12;
				// if (~bassDeg != 7, {
				// 	if (~bassDeg != 4, {
				// 		if (~bassDeg != 6, {
				// 			~bassDeg = [4, 6].choose;
				// 			}, {
				// 				~bassDeg = 7;
				// 				~firstRes = true;
				// 			}
				// 		);
				// 		}, {
				// 			~bassDeg = 7;
				// 			~firstRes = true;
				// 		}
				// 	);
				// });
				if(~bassDeg%7 != 0, {
					if(~bassDeg == 5, {
						~bassDeg = 4;
						~firstRes = true;
					});
					if(~bassDeg == 6, {
						~bassDeg = 7;
						~firstRes = true;
					});
					if(~bassDeg == 1, {
						~bassDeg = 0;
					});
				});
				// if(~bassDeg == 0, {
				// 	~bassDeg = 7;
				// });
				// ~bassLine.set(\freq, ~scale.degreeToFreq(~bassDeg, ~tonicFreq, 0));
				// ~bassLine.set(\freq, ~tonicFreq*(~pow**~bassShift));
			});
			~stab = ~stab + 1;
		});
		if(emph == true, {
			// Synth(\moveTone, [
			// 	\freq, freq/2,
			// 	\noise, 0.05,
			// ]);
			freqArray = freqArray.add(freq/2);
			// ~bassShift = 12 - [4, 2].choose;
			~bassDeg = [5, 6].choose;
			// ~bassLine.set(\freq, ~scale.degreeToFreq(~bassDeg, ~tonicFreq, 0));
			// ~bassLine.set(\freq, ~tonicFreq*(~pow**~bassShift));
			~stab = 0;
		});
		if(next.checkmate == true, {
			freqArray = freqArray.add(freq/2);
			freqArray = freqArray.add(freq/4);
			freqArray = freqArray.add(freq/8);
			out = ~delayBus;
			// "checkmate".postln;
		});
		if(queenCapt == true, {
			freqArray = freqArray.add(freq*2);
			out = ~delayBus;
			// "queen captured".postln;
		});
		if(rookCapt == true, {
			freqArray = freqArray.add(freq*2);
			// "rook captured".postln;
		});
		if(next.capture == true, {
			if(end == false, {
				~stab = 0;
				if(next.side == 0, {
					// freqArray = freqArray.add(freq*(~pow**5));
					freqArray = freqArray.add(~scale.degreeToFreq(deg+3, ~tonicFreq, 2));
				}, {
					// freqArray = freqArray.add(freq*(~pow**(-5)));
					freqArray = freqArray.add(~scale.degreeToFreq(deg-3, ~tonicFreq, 2));

				});
				// ~bassShift = 12 - [7, 5].choose;
				~bassDeg = [1, 5, 6].choose;
			});
			// ~bassLine.set(\freq, ~scale.degreeToFreq(~bassDeg, ~tonicFreq, 0));
			// ~bassLine.set(\freq, ~tonicFreq*(~pow**~bassShift));
		});
		if(next.check == true, {
			if(end == false, {
				~stab = 0;
				if(next.side == 0, {
					// freqArray = freqArray.add(freq*(~pow**7));
					freqArray = freqArray.add(~scale.degreeToFreq(deg+4, ~tonicFreq, 2));
					// freqArray = freqArray.add(freq*(~pow**10));
					freqArray = freqArray.add(~scale.degreeToFreq(deg+6, ~tonicFreq, 2));
				}, {
					// freqArray = freqArray.add(freq*(~pow**(-7)));
					freqArray = freqArray.add(~scale.degreeToFreq(deg-4, ~tonicFreq, 2));
					// freqArray = freqArray.add(freq*(~pow**(-10)));
					freqArray = freqArray.add(~scale.degreeToFreq(deg-6, ~tonicFreq, 2));
				});
				freqArray = freqArray*2;
				// ~bassShift = 12 - [7, 5, 10].choose;
				~bassDeg = [1, 6].choose;
			});

			// ~bassLine.set(\freq, ~scale.degreeToFreq(~bassDeg, ~tonicFreq, 0));

			// ~bassLine.set(\freq, ~tonicFreq*(~pow**~bassShift));
		});
		if (rrand(0.0, 1.0) > 0.9, {
			// ~scale = Scale.mixolydian;
			// ~offset = 3;

			~accentPattern = [0.2, 0.1, 0.1];
		});
		if (rrand(0.0, 1.0) < 0.1, {
			// ~scale = Scale.dorian;
			// ~offset = 0;
			~accentPattern = [0.2, 0.1, 0.1, 0.1]
		});
		freqArray.do({
			arg freq;
			Synth(\moveTone, [\freq, freq, \noise, 0.03, \out, out]);
		});

		// next.check.postln;

		nextFrame.rend;
	});
	};

	~reset = {

		~gameStream.reset;
		~counter = 0;
		~winner = nil;
		~firstCheck = false;
		~firstCapture = false;
		~firstRes = false;

		~stab = 0;
		// ~bassShift = 12;
		~bassDeg = 7;
		~bgAmp = 0;
		~rbAmp = 0;
		~hmAmp = 0;
		~hpAmp = 0;
		~dpAmp = 0;

		~bgNotes = [0, 2, 4];
		~accentPattern = [0.2, 0.1, 0.1, 0.1];
		~picRenderStream.reset;
	};

)


~gameStream.reset;

(
~reset.();

Pbindef(\bgMelody,
	\instrument, \moveTone,
	\scale, ~scale,
	\degree, Prand(~bgNotes, inf),
	// \degree, Pwrand(~bgNotes, ~bgWeights.normalizeSum, inf),
	\root, 0,
	\noise, Pwhite(0.03, 0.04),
	\atkTime, 0.01,
	\susTime, Pwrand([0.1, 0.2, 0.4]*~bgTime, ~bgRhythm.normalizeSum, inf),
	\relTime, 0.7,
	\dur, Pwrand([0.1, 0.2, 0.4]*~bgTime, ~bgRhythm.normalizeSum, inf),
	\amp, 0.2*~bgAmp,
	\pan, 0,
	\out, ~reverbBus
);
Pbindef(\bassRhythm,
	\instrument, \rhythmicBass,
	\scale, ~scale,
	\degree, Pwrand(~bassDeg + [0, 2, 4] - 14, [0.5, 0.3, 0.2], inf),
	\dur, 0.1*~bgTime,
	\amp, Pseq(~accentPattern*~rbAmp, inf),
	\pan, 0,
	\out, ~reverbBus
);
Pbindef(\highMelody,
	\instrument, \moveTone,
	\scale, ~scale,
	\degree, Pseq(~bgNotes + 14, inf),
	// \degree, Prand(~bgNotes, inf),
	\atkTime, 0.4,
	\susTime, Pwrand([0.1, 0.2, 0.4]*~hmTime, ~hmRhythm.normalizeSum, inf),
	\relTime, 2,
	// \dur, 0.01;
	\dur, Pseq([Pwrand([0.1, 0.2, 0.4]*~hmTime, ~hmRhythm.normalizeSum, 9), Pwhite(0.1*100, 0.1*200, 1)], inf),
	\amp, Pseq([1, 1.05, 1.1025, 1.1025, 1.047375, 0.99500625, 0.9452559375]*0.2*~hmAmp, inf),
	\pan, Pseq([Pseries(-1, 0.2, 10), Pseries(1, -0.2, 10)], inf),
	\out, ~reverbBus

);
Pbindef(\highPerc,
	\instrument, \moveTone,
	\noise, 0.02,
	\scale, ~scale,
	\degree, [~bassDeg, ~bassDeg + 2] + 14,
	\relTime, 1,
	\dur, Pseq([Pwrand([0.1, 0.2]*~bgTime, [4, 1].normalizeSum, 3), Pwhite(0.1*100*~bgTime, 0.1*250*~bgTime, 1)], inf),
	\amp, Pseq([0.2, 0.1, 0.1]*~hpAmp, inf),
	\out, ~reverbBus
);

Pbindef(\distantPing,
	\instrument, \moveTone,
	\scale, ~scale,
	\degree, ~bassDeg + 14,
	\noise, 0.02,
	\atkTime, 0.01,
	\relTime, 1,
	\dur, Pseq([Pseq([0.1*~hmTime], 5), Pwhite(0.1*50*~bgTime, 0.1*75*~bgTime, 1)], inf),
	\amp, Pseq([Pgeom(0.2, 0.8, 6)*~dpAmp], inf),
	\out, ~reverbBus
);

~step = {
	// ~bgNotes = [0, 1, 2, 3, 4, 5, 6, 7, \];
	// ~bgWeights = [4, 0, 2, 3, 4, 4, 0, 0, 0].normalizeSum;
	~next.();

	Pbindef(\bgMelody,
		\scale, ~scale,
		\degree, Prand(~bgNotes, inf),
		// \noise, Pwhite(0.02, 0.03),
		\atkTime, 0.01,
		\susTime, Pwrand([0.1, 0.2, 0.4]*~bgTime, [2, 4, 3].normalizeSum, inf),
		\relTime, 0.7,
		\dur, Pwrand([0.1, 0.2, 0.4]*~bgTime, [2, 4, 3].normalizeSum, inf),
		\amp, 0.1*~bgAmp
	);
	Pbindef(\bassRhythm,
		\scale, ~scale,
		\degree, Pwrand(~bassDeg + [0, 2, 4]-14, [0.5, 0.3, 0.2], inf),
		\dur, 0.1*~bgTime,
		\amp, Pseq(~accentPattern*~rbAmp, inf),
	);
	Pbindef(\highMelody,
		\scale, ~scale,
		\degree, Pseq(~bgNotes.collect({arg i; i + [0, 7].choose})+7, inf),
		\susTime, Pwrand([0.1, 0.2, 0.4]*~hmTime, ~hmRhythm.normalizeSum, inf),
		\relTime, 2,
		\dur, Pseq([Pwrand([0.1, 0.2, 0.4]*~hmTime, ~hmRhythm.normalizeSum, 9), Pwhite(0.1*100, 0.1*300, 1)], inf),
		\amp, Pseq([1, 1.05, 1.1025, 1.1025, 1.047375, 0.99500625, 0.9452559375]*0.1*~hmAmp, inf),
		\pan, Pseq([Pseries(-1, 0.2, 10), Pseries(1, -0.2, 10)], inf),
	);
	Pbindef(\highPerc,
		\instrument, \moveTone,
		\scale, ~scale,
		\degree, [~bassDeg, ~bassDeg + 2] + 14,
		\dur, Pseq([Pwrand([0.1, 0.2]*~bgTime, [4, 1].normalizeSum, 3), Prand([0.1*100*~bgTime, 0.1*300*~bgTime], 1)], inf),
		\amp, Pseq([0.2, 0.1, 0.1]*~hpAmp, inf),
		\out, ~reverbBus
	);
	Pbindef(\distantPing,
		\instrument, \moveTone,
		\scale, ~scale,
		\degree, ~bassDeg + 14,
		\noise, 0.02,
		\atkTime, 0.01,
		\relTime, 1,
		\dur, Pseq([Pseq([0.1*~hmTime], 5), Pwhite(0.1*50*~bgTime, 0.1*75*~bgTime, 1)], inf),
		\amp, Pseq([Pgeom(0.2, 0.8, 6)*~dpAmp], inf),
		\out, ~reverbBus
	);

	~bassLine.set(\freq, ~scale.degreeToFreq(~bassDeg, ~tonicFreq, 0));
	~bassLineDouble.set(\freq, ~scale.degreeToFreq(~bassDeg, ~tonicFreq, -1));
	// ~bassLine.set(\freq, ~tonicFreq*(~pow**~bassShift));
}
)

(
~bgm = Ppar([Pbindef(\bgMelody), Pbindef(\bassRhythm), Pbindef(\highMelody), Pbindef(\highPerc), Pbindef(\distantPing)]).play;
~bassLine = Synth(\bass, [\freq, ~tonicFreq*(~pow**12), \lo, 0.9, \hi, 1.1, \amp, 0, \out, ~reverbBus], ~bassGroup);
~bassLineDouble = Synth(\bass, [\freq, ~tonicFreq, \lo, 0.9, \hi, 1.1, \amp, 0, \out, ~reverbBus], ~bassGroup);
~delay = Synth(\delay, [\in, ~delayBus, \out, ~reverbBus], addAction:\addToTail);
~reverb = Synth(\reverb, [\in, ~reverbBus, \out, 0], addAction: \addToTail);

)


(
~picRenderStream.next.rend;
~dbAmp = 0.5;
Pbindef(\distantPing, \amp, Pseq([Pgeom(0.2, 0.8, 6)*~dpAmp], inf));

~bassLine.set(\amp, 0.7, \ampLag, 8);
)



Pbindef(\highMelody).play;

~step.();


(
Pbindef(\bgMelody,
	// \degree, Prand(~bgNotes-7, inf)
).stop;
)

(
~walk = Routine.new({
	var walk;
	{
		walk = ~bassWalk.([10, 11, 14].choose, 5, 1);
		walk.postln;
		walk.do({
			arg i;
			i.postln;
			~bassShift = i;
			~bassGroup.set(\freq, ~tonicFreq*(~pow**~bassShift));
			([0.2, 0.4, 0.8]*1.5).choose.wait;
		});
		((0.8)*4*1.5).wait;
		// walk.postln;
	}.loop;
});
)

~step.();

(
~walk.reset.play;
)


Synth(\pawn, [\freq, 300, \noise, 0.1]);
Synth(\queen, [\freq, 60.midicps, \noise, 0.05, \oct0, 2**rrand(0, -2), \oct1, 2**rrand(0, -2)]);


(

Pbind(
	\instrument, Prand([\pawn, \queen], inf),
	\scale, Scale.dorian,
	\degree, Pseq([Prand([0, 2, 3, 4, -1], 4), Pseq([Prand([2, -1]), 0])]),
	\dur, Pwhite(0.2, 0.7)

).play;
)




~beat = Synth(\rhythmicBass, [\freq, 110]);


~bassLine = Synth(\bass, [\freq, ~tonicFreq, \lo, 0.9, \hi, 1.1, \amp, 0.2]);
~bassLine.set(\lo, 0.9, \hi, 1.1);


(
~octCompress = {
	arg base, input, octDisplace = 0;
	var step, octUp;
	octUp = base*(2**(octDisplace+1));
	// base.postln;
	// input.postln;
	if (input >= octUp,
		{
			step = input/2;
			// step.postln;
			~octCompress.(base, step, octDisplace);
		},
		{
			input;
		}
	);
}
)

~octCompress.(440, 4400);
~tonicFreq*2

(
~tone = Synth(\tone, [\freq, ~tonicFreq*~pow.pow([0, 2, 4, 7, 9].choose)]);

)

(
var freq;
freq = ~octCompress.(~tonicFreq, ~tonicFreq*(rrand(50, 60)));
freq.postln;
~tone = Synth(\tone, [\freq, freq]);
)

(
~partialScale = 30.collect({
	arg i;
	var freq;
	freq = ~octCompress.(~tonicFreq, ~tonicFreq*(i+1));
	freq;
});
)

(
~createPartialScale = {
	arg tonic, size, startingPartial = 0;
	var scale;
	scale = [];
	(size*2).do({
		arg i;
		var freq;
		freq = ~octCompress.(tonic, tonic*(i+1));
		if(i > startingPartial, {

			if (scale.includes(freq) == false,
				{
					scale = scale.add(freq);
				}
			);
		};
		)
	});
	scale = scale.sort;
	// scale = scale.add([tonic, tonic*2]);
	scale;
};
)

~partialScale = ~createPartialScale.(~tonicFreq, 16);



(
~partialScale.do({
	arg i;
	// i.postln;
	if(~partialScale.includes(i),
		{
			"hi".postln;
		}
	);
});
)

~scale8 = ~createPartialScale.(1, 8);
~scale8*144;
(
var oScale = ~createPartialScale.(~tonicFreq, 16);
~scale8a = oScale.collect({
	arg i, j;
	// j.postln;
	if (j%2 == 0,
		{
			[oScale[j], oScale[j+1]];
		}
	);
});
~scale8a.do({
	arg i, j;
	if (i == nil, {
		~scale8a.removeAt(j)
	});
});
~scale8a;
)

~scale8a;

~scale16 = ~createPartialScale.(~tonicFreq, 16);

(
// ~melody = ([1, 2, 6, 7]*(rrand(0.8, 1.65))).collect({
// 	arg i;
// 	~scale8[i];
// });

~melody = 20.collect({
	arg i;
	var index;
	index = rrand(0, 7);
	// [~scale16[rrand(0, 16)], ~scale16[rrand(0, 16)]];
	~scale8a[index];
});

Pbindef(\melody,
	\instrument, \tone,
	// \freq, Pseq(~scale8*220, inf),
	\scale, Scale.dorian,
	\degree, Pseq([0, 1, 2, 3, 4]),
	// \freq, Pgeom(~tonicFreq, 1.01, inf),
	\dur, 0.5,
	// \lo, Pseq(Array.geom(~partialScale.size, 0.99, 0.99)),
	// \hi, Pseq(Array.geom(~partialScale.size, 1.01, 1.01)),
	// \lo, Pwhite(0.9, 0.99),
	// \hi, Pwhite(1.01, 1.1),
	\pan, Pwhite(-1.0, 1.0),

).play();
)



t;

(
~tonicFreq = 100;
Pbindef(\melody, \freq, Pseq(~melody*~tonicFreq, inf));
)
(
Pbind(
	\instrument, \tone,

)
)

(
~start = ~tonicMIDI+(12*2);
~melody = [0, rrand(-5, -4), rrand(-8, 11), -4, -9, -12]+~start;
Pbind(
	\instrument, \tone,
	\midinote, Pseq(~melody),
	// \dur, Pwhite(0.5, 0.8),
	\dur, Pwhite(0.5, 2),
	\lo, 0.85,
	\hi, 1.15,
	\pan, Pwhite(-1.0, 1.0),
	\amp, 0.5,
).play();
)
t = TempoClock.new();

t
t.beats;

(
Routine.new({
	~bassLine.set(\freq, ~tonicFreq*~pow.pow(-4));
	0.5.wait;
	~bassLine.set(\freq, ~tonicFreq*~pow.pow(-2));
	0.5.wait;
	~bassLine.set(\freq, ~tonicFreq*~pow.pow(0));

}).play(t, 1);
)


(
Routine.new({

});

)