# McDonnell Douglas MD-11 PFD
# Copyright (c) 2024 Josh Davidson (Octal450)

var pfd1 = nil;
var pfd1Display = nil;
var pfd1Error = nil;
var pfd2 = nil;
var pfd2Display = nil;
var pfd2Error = nil;

var Value = {
	Afs: {
		alt: 0,
		altSel: 0,
		apDisc: [0, 0],
		ap1: 0,
		ap1Avail: 0,
		ap2: 0,
		ap2Avail: 0,
		apSound: 0,
		ats: 0,
		atsFlash: 0,
		atsWarn: 0,
		fd1: 0,
		fd2: 0,
		hdg: 0,
		hdgSel: 0,
		kts: 0,
		ktsSel: 0,
		ktsMach: 0,
		ktsMachSel: 0,
		lat: 0,
		mach: 0,
		machSel: 0,
		land: "",
		pitch: "",
		pitchArm: "",
		roll: "",
		rollArm: "",
		spdProt: 0,
		thrust: "",
		vert: 0,
		vertText: "",
		vs: 0,
	},
	Ai: {
		alpha: 0,
		bankLimit: 0,
		center: nil,
		pitch: 0,
		roll: 0,
		stallAlphaDeg: 0,
	},
	Alt: {
		alert: 0,
		indicated: 0,
		indicatedAbs: 0,
		preSel: 0,
		sel: 0,
		Tape: {
			five: 0,
			fiveT: "",
			four: 0,
			fourT: "",
			hundreds: 0,
			hundredsGeneva: 0,
			middleOffset: 0,
			middleText: 0,
			offset: 0,
			one: 0,
			oneT: "",
			tenThousands: 0,
			tenThousandsGeneva: 0,
			thousands: 0,
			thousandsGeneva: 0,
			three: 0,
			threeT: "",
			tens: 0,
			two: 0,
			twoT: "",
		},
	},
	Asi: {
		f15: 0,
		f28: 0,
		f35: 0,
		f50: 0,
		flapGearMax: 0,
		ias: 0,
		mach: 0,
		preSel: 0,
		sel: 0,
		trend: 0,
		vmin: 0,
		vmoMmo: 0,
		vss: 0,
		Tape: {
			f15: 0,
			f28: 0,
			f35: 0,
			f50: 0,
			flapGearMax: 0,
			fr: 0,
			ge: 0,
			gr: 0,
			ias: 0,
			preSel: 0,
			se: 0,
			sel: 0,
			sr: 0,
			vmin: 0,
			vmoMmo: 0,
			vss: 0,
		},
	},
	Hdg: {
		hideHdgSel: 0,
		indicated: 0,
		preSel: 0,
		sel: 0,
		showHdg: 0,
		Tape: {
			preSel: 0,
			sel: 0,
		},
		text: 0,
		track: 0,
	},
	Iru: {
		aligned: [0, 0, 0],
		aligning: [0, 0, 0],
		mainAvail: [0, 0, 0],
		source: [0, 1],
	},
	Misc: {
		blinkMed: 0,
		blinkMed2: 0,
		flapsCmd: 0,
		flapsOut: 0,
		flapsPos: 0,
		gearOut: 0,
		minimums: 0,
		slatsCmd: 0,
		slatsOut: 0,
		slatsPos: 0,
		wow: 0,
	},
	Nav: {
		gsInRange: 0,
		gsNeedleDeflectionNorm: 0,
		headingNeedleDeflectionNorm: 0,
		selectedMhz: 0,
		signalQuality: 0,
	},
	Qnh: {
		inhg: 0,
	},
	Ra: {
		agl: 0,
	},
	Vs: {
		digit: 0,
		indicated: 0,
	},
};

var canvasBase = {
	init: func(canvasGroup, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(canvasGroup, file, {"font-mapper": font_mapper});
		
		var svgKeys = me.getKeys();
		foreach(var key; svgKeys) {
			me[key] = canvasGroup.getElementById(key);
			
			var clip_el = canvasGroup.getElementById(key ~ "_clip");
			if (clip_el != nil) {
				clip_el.setVisible(0);
				var tranRect = clip_el.getTransformedBounds();
				
				var clip_rect = sprintf("rect(%d, %d, %d, %d)", 
					tranRect[1], # 0 ys
					tranRect[2], # 1 xe
					tranRect[3], # 2 ye
					tranRect[0] # 3 xs
				);
				
				# Coordinates are top, right, bottom, left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
				me[key].set("clip", clip_rect);
				me[key].set("clip-frame", canvas.Element.PARENT);
			}
		}
		
		Value.Ai.center = me["AI_center"].getCenter();
		me.aiHorizonTrans = me["AI_horizon"].createTransform();
		me.aiHorizonRot = me["AI_horizon"].createTransform();
		
		me.AI_fpv_trans = me["AI_fpv"].createTransform();
		me.AI_fpv_rot = me["AI_fpv"].createTransform();
		
		me.AI_fpd_trans = me["AI_fpd"].createTransform();
		me.AI_fpd_rot = me["AI_fpd"].createTransform();
		
		me.page = canvasGroup;
		
		return me;
	},
	getKeys: func() {
		return ["FMA_Speed", "FMA_Thrust", "FMA_Thrust_Arm", "FMA_Roll", "FMA_Roll_Arm", "FMA_Pitch", "FMA_Pitch_Land", "FMA_Land", "FMA_Pitch_Arm", "FMA_Altitude_Thousand", "FMA_Altitude", "FMA_ATS_Thrust_Off", "FMA_ATS_Pitch_Off", "FMA_AP_Pitch_Off_Box",
		"FMA_AP_Thrust_Off_Box", "FMA_AP", "ASI_ias_group", "ASI_taxi_group", "ASI_taxi", "ASI_groundspeed", "ASI_v_speed", "ASI_scale", "ASI_bowtie_mach", "ASI", "ASI_mach", "ASI_mach_decimal", "ASI_bowtie_L", "ASI_bowtie_R", "ASI_presel", "ASI_sel",
		"ASI_sel_up", "ASI_sel_up_text", "ASI_sel_dn", "ASI_sel_dn_text", "ASI_trend_up", "ASI_trend_dn", "ASI_vmo", "ASI_vmo_bar", "ASI_vmo_bar2", "ASI_flap_max", "ASI_vss", "ASI_vmin", "ASI_vmin_bar", "ASI_ref_bugs", "ASI_gr", "ASI_ge", "ASI_sr", "ASI_se",
		"ASI_fr", "ASI_f15", "ASI_f28", "ASI_f35", "ASI_f50", "AI_center", "AI_horizon", "AI_scale", "AI_bank", "AI_slipskid", "AI_overbank_index", "AI_banklimit_L", "AI_banklimit_R", "AI_PLI", "AI_group", "AI_group2", "AI_group3", "AI_error", "AI_fpv", "AI_fpd",
		"AI_arrow_up", "AI_arrow_dn", "AI_rising_runway", "FD_roll", "FD_pitch", "FD_group", "ALT_minus", "ALT_tenthousands", "ALT_thousands", "ALT_thousands_zero", "ALT_hundreds", "ALT_tens", "ALT_scale", "ALT_scale_num", "ALT_one", "ALT_two", "ALT_three",
		"ALT_four", "ALT_five", "ALT_one_T", "ALT_two_T", "ALT_three_T", "ALT_four_T", "ALT_five_T", "ALT_presel", "ALT_sel", "ALT_sel_up", "ALT_sel_up_text_T", "ALT_sel_up_text", "ALT_sel_dn", "ALT_sel_dn_text_T", "ALT_sel_dn_text", "ALT_agl", "ALT_bowtie",
		"VSI_needle_up", "VSI_needle_dn", "VSI_up", "VSI_dn", "VSI_bug_up", "VSI_bug_dn", "VSI_group", "VSI_error", "HDG", "HDG_dial", "HDG_presel", "HDG_sel", "HDG_group", "HDG_error", "HDG_sel_left_text", "HDG_sel_right_text", "HDG_mode", "HDG_magtru",
		"TRK_pointer", "TCAS_fail", "TCAS_off", "Slats", "Slats_auto", "Slats_no", "Slats_up", "Slats_dn", "Flaps", "Flaps_up", "Flaps_dn", "Flaps_num", "Flaps_num2", "Flaps_num_boxes", "QNH", "LOC_scale", "LOC_pointer", "LOC_no", "GS_scale", "GS_pointer",
		"GS_no", "ILS_Info", "ILS_DME", "RA", "RA_box", "Minimums", "Inner_Marker", "Middle_Marker", "Outer_Marker"];
	},
	setup: func() {
		# Hide the pages by default
		pfd1.page.hide();
		pfd1Error.page.hide();
		pfd2.page.hide();
		pfd2Error.page.hide();
	},
	update: func() {
		if (systems.DUController.updatePfd1) {
			pfd1.update();
		}
		if (systems.DUController.updatePfd2) {
			pfd2.update();
		}
	},
	updateBase: func(n) {
		Value.Afs.hdgSel = afs.Input.hdg.getValue();
		Value.Afs.kts = afs.Internal.kts.getValue();
		Value.Afs.ktsSel = afs.Input.kts.getValue();
		Value.Afs.ktsMach = afs.Internal.ktsMach.getBoolValue();
		Value.Afs.ktsMachSel = afs.Input.ktsMach.getBoolValue();
		Value.Afs.lat = afs.Output.lat.getValue();
		Value.Afs.mach = afs.Internal.mach.getValue();
		Value.Afs.machSel = afs.Input.mach.getValue();
		Value.Afs.vert = afs.Output.vert.getValue();
		Value.Afs.vertText = afs.Text.vert.getValue();
		Value.Asi.flapGearMax = fms.Speeds.flapGearMax.getValue();
		Value.Asi.ias = pts.Instrumentation.AirspeedIndicator.indicatedSpeedKt.getValue();
		Value.Asi.mach = pts.Instrumentation.AirspeedIndicator.indicatedMach.getValue();
		Value.Asi.preSel = pts.Instrumentation.Pfd.spdPreSel.getValue();
		Value.Asi.sel = pts.Instrumentation.Pfd.spdSel.getValue();
		Value.Asi.trend = pts.Instrumentation.Pfd.speedTrend.getValue();
		Value.Asi.vmin = fms.Speeds.vminTape.getValue();
		Value.Asi.vmoMmo = fms.Speeds.vmoMmo.getValue();
		Value.Asi.vss = fms.Speeds.vssTape.getValue();
		Value.Misc.blinkMed = pts.Fdm.JSBsim.Libraries.blinkMed.getBoolValue();
		Value.Misc.blinkMed2 = pts.Fdm.JSBsim.Libraries.blinkMed2.getBoolValue();
		Value.Misc.flapsCmd = pts.Controls.Flight.flapsCmd.getValue();
		Value.Misc.flapsPos = pts.Fdm.JSBsim.Fcs.flapPosDeg.getValue();
		Value.Misc.slatsCmd = pts.Controls.Flight.slatsCmd.getValue();
		Value.Misc.slatsPos = pts.Fdm.JSBsim.Fcs.slatPosDeg.getValue();
		Value.Misc.flapsOut = Value.Misc.flapsCmd >= 0.1 or Value.Misc.flapsPos >= 0.1;
		Value.Misc.slatsOut = Value.Misc.slatsCmd >= 0.1 or Value.Misc.slatsPos >= 0.1;
		Value.Misc.gearOut = pts.Fdm.JSBsim.Gear.gearAllNorm.getValue() > 0;
		Value.Misc.wow = pts.Fdm.JSBsim.Position.wow.getBoolValue();
		
		# ASI
		me["ASI_v_speed"].hide(); # Not working yet
		
		# Subtract 50, since the scale starts at 50, but don't allow less than 0, or more than 500 situations
		if (Value.Asi.ias <= 50) {
			Value.Asi.Tape.ias = 0;
		} else if (Value.Asi.ias >= 500) {
			Value.Asi.Tape.ias = 450;
		} else {
			Value.Asi.Tape.ias = Value.Asi.ias - 50;
		}
		
		if (Value.Asi.preSel <= 50) {
			Value.Asi.Tape.preSel = 0 - Value.Asi.Tape.ias;
		} else if (Value.Asi.preSel >= 500) {
			Value.Asi.Tape.preSel = 450 - Value.Asi.Tape.ias;
		} else {
			Value.Asi.Tape.preSel = Value.Asi.preSel - 50 - Value.Asi.Tape.ias;
		}
		
		if (Value.Asi.sel <= 50) {
			Value.Asi.Tape.sel = 0 - Value.Asi.Tape.ias;
		} else if (Value.Asi.sel >= 500) {
			Value.Asi.Tape.sel = 450 - Value.Asi.Tape.ias;
		} else {
			Value.Asi.Tape.sel = Value.Asi.sel - 50 - Value.Asi.Tape.ias;
		}
		
		if (Value.Asi.ias < 53 and Value.Misc.wow) {
			if (Value.Iru.aligning[0] or Value.Iru.aligning[1] or Value.Iru.aligning[2]) {
				me["ASI_groundspeed"].setColor(0.9412,0.7255,0);
				me["ASI_groundspeed"].setText("NO");
				me["ASI_taxi"].setColor(0.9412,0.7255,0);
			} else if (!Value.Iru.aligned[Value.Iru.source[n]]) {
				me["ASI_groundspeed"].setColor(1,1,1);
				me["ASI_groundspeed"].setText("--");
				me["ASI_taxi"].setColor(1,1,1);
			} else {
				me["ASI_groundspeed"].setColor(1,1,1);
				me["ASI_groundspeed"].setText(sprintf("%d", math.round(pts.Velocities.groundspeedKt.getValue())));
				me["ASI_taxi"].setColor(1,1,1);
			}
			
			me["ASI_sel_up"].setColor(1,1,1);
			me["ASI_sel_dn"].setColor(1,1,1);
			me["ASI_ias_group"].hide();
			me["ASI_taxi_group"].show();
		} else {
			if (Value.Asi.vmoMmo <= 50) {
				Value.Asi.Tape.vmoMmo = 0 - Value.Asi.Tape.ias;
			} else if (Value.Asi.vmoMmo >= 500) {
				Value.Asi.Tape.vmoMmo = 450 - Value.Asi.Tape.ias;
			} else {
				Value.Asi.Tape.vmoMmo = Value.Asi.vmoMmo - 50 - Value.Asi.Tape.ias;
			}
			
			if (Value.Asi.flapGearMax < 0) {
				Value.Asi.Tape.flapGearMax = 0;
				me["ASI_flap_max"].hide();
				me["ASI_vmo_bar"].show();
				me["ASI_vmo_bar2"].hide();
			} else if (Value.Asi.flapGearMax <= 50) {
				Value.Asi.Tape.flapGearMax = 0 - Value.Asi.Tape.ias;
				me["ASI_flap_max"].show();
				me["ASI_vmo_bar"].hide();
				me["ASI_vmo_bar2"].show();
			} else if (Value.Asi.flapGearMax >= 500) {
				Value.Asi.Tape.flapGearMax = 450 - Value.Asi.Tape.ias;
				me["ASI_flap_max"].show();
				me["ASI_vmo_bar"].hide();
				me["ASI_vmo_bar2"].show();
			} else {
				Value.Asi.Tape.flapGearMax = Value.Asi.flapGearMax - 50 - Value.Asi.Tape.ias;
				me["ASI_flap_max"].show();
				me["ASI_vmo_bar"].hide();
				me["ASI_vmo_bar2"].show();
			}
			
			Value.Asi.Tape.vmin = Value.Asi.vss - math.clamp(Value.Asi.vmin, 0, fms.Speeds.vmax.getValue());
			
			if (Value.Asi.vss < 0) {
				me["ASI_vss"].hide();
			} else if (Value.Asi.vss <= 50) {
				Value.Asi.Tape.vss = 0 - Value.Asi.Tape.ias;
				me["ASI_vss"].show();
			} else if (Value.Asi.vss >= 500) {
				Value.Asi.Tape.vss = 450 - Value.Asi.Tape.ias;
				me["ASI_vss"].show();
			} else {
				Value.Asi.Tape.vss = Value.Asi.vss - 50 - Value.Asi.Tape.ias;
				me["ASI_vss"].show();
			}
			
			me["ASI_scale"].setTranslation(0, Value.Asi.Tape.ias * 4.48656);
			me["ASI_vmo"].setTranslation(0, Value.Asi.Tape.vmoMmo * -4.48656);
			me["ASI_flap_max"].setTranslation(0, Value.Asi.Tape.flapGearMax * -4.48656);
			me["ASI_vss"].setTranslation(0, Value.Asi.Tape.vss * -4.48656);
			me["ASI_vmin"].setTranslation(0, Value.Asi.Tape.vmin * -4.48656);
			me["ASI_vmin_bar"].setTranslation(0, Value.Asi.Tape.vmin * -4.48656);
			me["ASI"].setText(sprintf("%3.0f", math.round(Value.Asi.ias)));
			
			if (Value.Asi.mach > 0.465) {
				if (Value.Asi.mach >= 0.999) {
					me["ASI_mach"].setText("999");
				} else {
					me["ASI_mach"].setText(sprintf("%3.0f", Value.Asi.mach * 1000));
				}
				me["ASI_bowtie_mach"].show();
			} else if (Value.Asi.mach >= 0.445) {
				if (Value.Asi.mach >= 0.999) {
					me["ASI_mach"].setText("999");
				} else {
					me["ASI_mach"].setText(sprintf("%3.0f", Value.Asi.mach * 1000));
				}
			} else if (Value.Asi.mach < 0.445) {
				me["ASI_bowtie_mach"].hide();
			}
			
			if (Value.Asi.ias > Value.Asi.vmoMmo) {
				me["ASI"].setColor(1,0,0);
				me["ASI_bowtie_L"].setColor(1,0,0);
				me["ASI_bowtie_R"].setColor(1,0,0);
				me["ASI_mach"].setColor(1,0,0);
				me["ASI_mach_decimal"].setColor(1,0,0);
			} else if (Value.Asi.ias < Value.Asi.vss) {
				me["ASI"].setColor(1,0,0);
				me["ASI_bowtie_L"].setColor(1,0,0);
				me["ASI_bowtie_R"].setColor(1,0,0);
				me["ASI_mach"].setColor(1,0,0);
				me["ASI_mach_decimal"].setColor(1,0,0);
			} else if (Value.Asi.ias > Value.Asi.flapGearMax and Value.Asi.flapGearMax >= 0) {
				me["ASI"].setColor(0.9647,0.8196,0.0784);
				me["ASI_bowtie_L"].setColor(0.9647,0.8196,0.0784);
				me["ASI_bowtie_R"].setColor(0.9647,0.8196,0.0784);
				me["ASI_mach"].setColor(0.9647,0.8196,0.0784);
				me["ASI_mach_decimal"].setColor(0.9647,0.8196,0.0784);
			} else if (Value.Asi.ias < Value.Asi.vmin) {
				me["ASI"].setColor(0.9647,0.8196,0.0784);
				me["ASI_bowtie_L"].setColor(0.9647,0.8196,0.0784);
				me["ASI_bowtie_R"].setColor(0.9647,0.8196,0.0784);
				me["ASI_mach"].setColor(0.9647,0.8196,0.0784);
				me["ASI_mach_decimal"].setColor(0.9647,0.8196,0.0784);
			} else {
				me["ASI"].setColor(1,1,1);
				me["ASI_bowtie_L"].setColor(1,1,1);
				me["ASI_bowtie_R"].setColor(1,1,1);
				me["ASI_mach"].setColor(1,1,1);
				me["ASI_mach_decimal"].setColor(1,1,1);
			}
			
			# Reference Speed Bugs
			if (Value.Misc.gearOut) {
				Value.Asi.Tape.gr = fms.Speeds.gearRetMax.getValue() - 50 - Value.Asi.Tape.ias;
				if (Value.Asi.Tape.gr > 0) {
					me["ASI_gr"].setColor(0,1,0);
				} else {
					me["ASI_gr"].setColor(0.9647,0.8196,0.0784);
				}
				me["ASI_gr"].setTranslation(0, Value.Asi.Tape.gr * -4.48656);
				me["ASI_gr"].show();
			} else {
				me["ASI_gr"].hide();
			}
			
			Value.Asi.Tape.ge = fms.Speeds.gearExtMax.getValue() - 50 - Value.Asi.Tape.ias;
			if (Value.Asi.Tape.ge > 0) {
				me["ASI_ge"].setColor(0,1,0);
			} else {
				me["ASI_ge"].setColor(0.9647,0.8196,0.0784);
			}
			me["ASI_ge"].setTranslation(0, Value.Asi.Tape.ge * -4.48656);
			
			if (Value.Misc.slatsOut) {
				Value.Asi.Tape.sr = fms.Speeds.vsr.getValue() - 50 - Value.Asi.Tape.ias;
				if (Value.Asi.Tape.sr < 0) {
					me["ASI_sr"].setColor(0,1,0);
				} else {
					me["ASI_sr"].setColor(0.9647,0.8196,0.0784);
				}
				me["ASI_sr"].setTranslation(0, Value.Asi.Tape.sr * -4.48656);
				me["ASI_sr"].show();
			} else {
				me["ASI_sr"].hide();
			}
			
			if (!Value.Misc.slatsOut) {
				Value.Asi.Tape.se = fms.Speeds.slatMax.getValue() - 50 - Value.Asi.Tape.ias;
				if (Value.Asi.Tape.se > 0) {
					me["ASI_se"].setColor(0,1,0);
				} else {
					me["ASI_se"].setColor(0.9647,0.8196,0.0784);
				}
				me["ASI_se"].setTranslation(0, Value.Asi.Tape.se * -4.48656);
				me["ASI_se"].show();
			} else {
				me["ASI_se"].hide();
			}
			
			if (Value.Misc.flapsOut) {
				Value.Asi.Tape.fr = fms.Speeds.vfr.getValue() - 50 - Value.Asi.Tape.ias;
				if (Value.Asi.Tape.fr < 0) {
					me["ASI_fr"].setColor(0,1,0);
				} else {
					me["ASI_fr"].setColor(0.9647,0.8196,0.0784);
				}
				me["ASI_fr"].setTranslation(0, Value.Asi.Tape.fr * -4.48656);
				me["ASI_fr"].show();
			} else {
				me["ASI_fr"].hide();
			}
			
			Value.Asi.f15 = fms.Speeds.flap15Max.getValue();
			Value.Asi.f28 = fms.Speeds.flap28Max.getValue();
			Value.Asi.f35 = fms.Speeds.flap35Max.getValue();
			Value.Asi.f50 = fms.Speeds.flap50Max.getValue();
			
			if (Value.Misc.flapsCmd >= 49.9 or Value.Misc.flapsPos >= 49.9) {
				me["ASI_f15"].hide();
				me["ASI_f28"].hide();
				me["ASI_f35"].hide();
				me["ASI_f50"].hide();
			} else if ((Value.Misc.flapsCmd >= 34.9 or Value.Misc.flapsPos >= 34.9) or (Value.Asi.ias < Value.Asi.f50 and Value.Misc.slatsOut) and Value.Afs.vertText != "T/O CLB") {
				me["ASI_f15"].hide();
				me["ASI_f28"].hide();
				me["ASI_f35"].hide();
				
				Value.Asi.Tape.f50 = Value.Asi.f50 - 50 - Value.Asi.Tape.ias;
				if (Value.Asi.Tape.f50 > 0) {
					me["ASI_f50"].setColor(0,1,0);
				} else {
					me["ASI_f50"].setColor(0.9647,0.8196,0.0784);
				}
				me["ASI_f50"].setTranslation(0, Value.Asi.Tape.f50 * -4.48656);
				me["ASI_f50"].show();
			} else if ((Value.Misc.flapsCmd >= 27.9 or Value.Misc.flapsPos >= 27.9) or (Value.Asi.ias < Value.Asi.f35 and Value.Misc.slatsOut) and Value.Afs.vertText != "T/O CLB") {
				me["ASI_f15"].hide();
				me["ASI_f28"].hide();
				
				Value.Asi.Tape.f35 = Value.Asi.f35 - 50 - Value.Asi.Tape.ias;
				if (Value.Asi.Tape.f35 > 0) {
					me["ASI_f35"].setColor(0,1,0);
				} else {
					me["ASI_f35"].setColor(0.9647,0.8196,0.0784);
				}
				me["ASI_f35"].setTranslation(0, Value.Asi.Tape.f35 * -4.48656);
				me["ASI_f35"].show();
				
				me["ASI_f50"].hide();
			} else if ((Value.Misc.flapsCmd >= 14.9 or Value.Misc.flapsPos >= 14.9) or (Value.Asi.ias < Value.Asi.f28 and Value.Misc.slatsOut) and Value.Afs.vertText != "T/O CLB") {
				me["ASI_f15"].hide();
				
				Value.Asi.Tape.f28 = Value.Asi.f28 - 50 - Value.Asi.Tape.ias;
				if (Value.Asi.Tape.f28 > 0) {
					me["ASI_f28"].setColor(0,1,0);
				} else {
					me["ASI_f28"].setColor(0.9647,0.8196,0.0784);
				}
				me["ASI_f28"].setTranslation(0, Value.Asi.Tape.f28 * -4.48656);
				me["ASI_f28"].show();
				
				me["ASI_f35"].hide();
				me["ASI_f50"].hide();
			} else if (Value.Misc.slatsOut and Value.Afs.vertText != "T/O CLB") {
				Value.Asi.Tape.f15 = Value.Asi.f15 - 50 - Value.Asi.Tape.ias;
				if (Value.Asi.Tape.f15 > 0) {
					me["ASI_f15"].setColor(0,1,0);
				} else {
					me["ASI_f15"].setColor(0.9647,0.8196,0.0784);
				}
				me["ASI_f15"].setTranslation(0, Value.Asi.Tape.f15 * -4.48656);
				me["ASI_f15"].show();
				
				me["ASI_f28"].hide();
				me["ASI_f35"].hide();
				me["ASI_f50"].hide();
			} else {
				me["ASI_f15"].hide();
				me["ASI_f28"].hide();
				me["ASI_f35"].hide();
				me["ASI_f50"].hide();
			}
			
			# Let the whole ASI tape update before showing
			me["ASI_ias_group"].show();
			me["ASI_taxi_group"].hide();
		}
		
		if (Value.Asi.trend >= 2) {
			me["ASI_trend_dn"].hide();
			me["ASI_trend_up"].setTranslation(0, math.clamp(Value.Asi.trend, 0, 60) * -4.48656);
			me["ASI_trend_up"].show();
		} else if (Value.Asi.trend <= -2) {
			me["ASI_trend_dn"].setTranslation(0, math.clamp(Value.Asi.trend, -60, 0) * -4.48656);
			me["ASI_trend_dn"].show();
			me["ASI_trend_up"].hide();
		} else {
			me["ASI_trend_dn"].hide();
			me["ASI_trend_up"].hide();
		}
		
		# ASI Pre-Sel/Sel
		me["ASI_presel"].setTranslation(0, Value.Asi.Tape.preSel * -4.48656);
		me["ASI_sel"].setTranslation(0, Value.Asi.Tape.sel * -4.48656);
		
		if (Value.Asi.Tape.preSel < -60 or Value.Asi.Tape.preSel > 60 or afs.Internal.syncedSpd) {
			me["ASI_presel"].hide();
		} else {
			if (Value.Asi.preSel > Value.Asi.vmoMmo and Value.Asi.flapGearMax >= 0) {
				me["ASI_presel"].setColor(1,0,0);
			} else if (Value.Asi.preSel > Value.Asi.vmoMmo - 5) { # No flapGearMax bar
				me["ASI_presel"].setColor(1,0,0);
			} else if (Value.Asi.preSel < Value.Asi.vss) {
				me["ASI_presel"].setColor(1,0,0);
			} else if (Value.Asi.preSel > Value.Asi.flapGearMax - 5 and Value.Asi.flapGearMax >= 0) {
				me["ASI_presel"].setColor(0.9647,0.8196,0.0784);
			} else if (Value.Asi.preSel < Value.Asi.vmin + 5) {
				me["ASI_presel"].setColor(0.9647,0.8196,0.0784);
			} else {
				me["ASI_presel"].setColor(1,1,1);
			}
			me["ASI_presel"].show();
		}
		if (Value.Asi.Tape.sel < -60 or Value.Asi.Tape.sel > 60) {
			me["ASI_sel"].hide();
		} else {
			me["ASI_sel"].show();
		}
		
		if (Value.Asi.Tape.preSel > 60 and !afs.Internal.syncedSpd) {
			if (Value.Asi.preSel > Value.Asi.vmoMmo and Value.Asi.flapGearMax >= 0) {
				me["ASI_sel_up"].setColor(1,0,0);
				me["ASI_sel_up_text"].setColor(1,0,0);
			} else if (Value.Asi.preSel > Value.Asi.vmoMmo - 5) { # No flapGearMax bar
				me["ASI_sel_up"].setColor(1,0,0);
				me["ASI_sel_up_text"].setColor(1,0,0);
			} else if (Value.Asi.preSel < Value.Asi.vss) {
				me["ASI_sel_up"].setColor(1,0,0);
				me["ASI_sel_up_text"].setColor(1,0,0);
			} else if (Value.Asi.preSel > Value.Asi.flapGearMax - 5 and Value.Asi.flapGearMax >= 0) {
				me["ASI_sel_up"].setColor(0.9647,0.8196,0.0784);
				me["ASI_sel_up_text"].setColor(0.9647,0.8196,0.0784);
			} else if (Value.Asi.preSel < Value.Asi.vmin + 5) {
				me["ASI_sel_up"].setColor(0.9647,0.8196,0.0784);
				me["ASI_sel_up_text"].setColor(0.9647,0.8196,0.0784);
			} else {
				me["ASI_sel_up"].setColor(1,1,1);
				me["ASI_sel_up_text"].setColor(1,1,1);
			}
			me["ASI_sel_up"].setColorFill(0,0,0);
			me["ASI_sel_up"].show();
			if (Value.Afs.ktsMachSel) {
				me["ASI_sel_up_text"].setText("." ~ sprintf("%3.0f", Value.Afs.machSel * 1000));
			} else {
				me["ASI_sel_up_text"].setText(sprintf("%3.0f", Value.Afs.ktsSel));
			}
			me["ASI_sel_up_text"].show();
		} else if (Value.Asi.Tape.sel > 60) { # It will never go outside envelope, so keep it white
			me["ASI_sel_up"].setColor(1,1,1);
			me["ASI_sel_up"].setColorFill(1,1,1);
			me["ASI_sel_up_text"].setColor(1,1,1);
			me["ASI_sel_up"].show();
			if (Value.Afs.ktsMach) {
				me["ASI_sel_up_text"].setText("." ~ sprintf("%3.0f", Value.Afs.mach * 1000));
			} else {
				me["ASI_sel_up_text"].setText(sprintf("%3.0f", Value.Afs.kts));
			}
			me["ASI_sel_up_text"].show();
		} else {
			me["ASI_sel_up"].hide();
			me["ASI_sel_up_text"].hide();
		}
		if (Value.Asi.Tape.preSel < -60 and !afs.Internal.syncedSpd) {
			if (Value.Asi.preSel > Value.Asi.vmoMmo and Value.Asi.flapGearMax >= 0) {
				me["ASI_sel_dn"].setColor(1,0,0);
				me["ASI_sel_dn_text"].setColor(1,0,0);
			} else if (Value.Asi.preSel > Value.Asi.vmoMmo - 5) { # No flapGearMax bar
				me["ASI_sel_dn"].setColor(1,0,0);
				me["ASI_sel_dn_text"].setColor(1,0,0);
			} else if (Value.Asi.preSel < Value.Asi.vss) {
				me["ASI_sel_dn"].setColor(1,0,0);
				me["ASI_sel_dn_text"].setColor(1,0,0);
			} else if (Value.Asi.preSel > Value.Asi.flapGearMax - 5 and Value.Asi.flapGearMax >= 0) {
				me["ASI_sel_dn"].setColor(0.9647,0.8196,0.0784);
				me["ASI_sel_dn_text"].setColor(0.9647,0.8196,0.0784);
			} else if (Value.Asi.preSel < Value.Asi.vmin + 5) {
				me["ASI_sel_dn"].setColor(0.9647,0.8196,0.0784);
				me["ASI_sel_dn_text"].setColor(0.9647,0.8196,0.0784);
			} else {
				me["ASI_sel_dn"].setColor(1,1,1);
				me["ASI_sel_dn_text"].setColor(1,1,1);
			}
			me["ASI_sel_dn"].setColorFill(0,0,0);
			me["ASI_sel_dn"].show();
			if (Value.Afs.ktsMachSel) {
				me["ASI_sel_dn_text"].setText("." ~ sprintf("%3.0f", Value.Afs.machSel * 1000));
			} else {
				me["ASI_sel_dn_text"].setText(sprintf("%3.0f", Value.Afs.ktsSel));
			}
			me["ASI_sel_dn_text"].show();
		} else if (Value.Asi.Tape.sel < -60) { # It will never go outside envelope, so keep it white
			me["ASI_sel_dn"].setColor(1,1,1);
			me["ASI_sel_dn"].setColorFill(1,1,1);
			me["ASI_sel_dn_text"].setColor(1,1,1);
			me["ASI_sel_dn"].show();
			if (Value.Afs.ktsMach) {
				me["ASI_sel_dn_text"].setText("." ~ sprintf("%3.0f", Value.Afs.mach * 1000));
			} else {
				me["ASI_sel_dn_text"].setText(sprintf("%3.0f", Value.Afs.kts));
			}
			me["ASI_sel_dn_text"].show();
		} else {
			me["ASI_sel_dn"].hide();
			me["ASI_sel_dn_text"].hide();
		}
		
		# AI
		Value.Ai.alpha = pts.Fdm.JSBsim.Aero.alphaDegDamped.getValue();
		Value.Ai.bankLimit = pts.Instrumentation.Pfd.bankLimit.getValue();
		Value.Ai.pitch = pts.Orientation.pitchDeg.getValue();
		Value.Ai.roll = pts.Orientation.rollDeg.getValue();
		Value.Ai.stallAlphaDeg = pts.Fdm.JSBsim.Fcc.stallAlphaDeg.getValue();
		Value.Hdg.track = pts.Instrumentation.Pfd.trackBug[0].getValue();
		
		me.aiHorizonTrans.setTranslation(0, Value.Ai.pitch * 10.246);
		me.aiHorizonRot.setRotation(-Value.Ai.roll * D2R, Value.Ai.center);
		
		me["AI_slipskid"].setTranslation(pts.Instrumentation.Pfd.slipSkid.getValue() * 7, 0);
		me["AI_bank"].setRotation(-Value.Ai.roll * D2R);
		
		me["AI_banklimit_L"].setRotation(Value.Ai.bankLimit * -D2R);
		me["AI_banklimit_R"].setRotation(Value.Ai.bankLimit * D2R);
		
		if (abs(Value.Ai.roll) >= 30.5) {
			me["AI_overbank_index"].show();
		} else {
			me["AI_overbank_index"].hide();
		}
		
		if (afs.Input.vsFpa.getBoolValue()) {
			me.AI_fpv_trans.setTranslation(math.clamp(Value.Hdg.track, -20, 20) * 10.246, math.clamp(Value.Ai.alpha, -20, 20) * 10.246);
			me.AI_fpv_rot.setRotation(-Value.Ai.roll * D2R, Value.Ai.center);
			me["AI_fpv"].setRotation(Value.Ai.roll * D2R); # It shouldn't be rotated, only the axis should be
			me["AI_fpv"].show();
		} else {
			me["AI_fpv"].hide();
		}
		
		if (Value.Afs.vert == 5) {
			me.AI_fpd_trans.setTranslation(0, (Value.Ai.pitch - afs.Input.fpa.getValue()) * 10.246);
			me.AI_fpd_rot.setRotation(-Value.Ai.roll * D2R, Value.Ai.center);
			me["AI_fpd"].show();
		} else {
			me["AI_fpd"].hide();
		}
		
		me["AI_PLI"].setTranslation(0, math.clamp(Value.Ai.stallAlphaDeg - Value.Ai.alpha, -20, 20) * -10.246);
		if (Value.Ai.alpha >= Value.Ai.stallAlphaDeg) {
			me["AI_PLI"].setColor(1,0,0);
			me["AI_banklimit_L"].setColor(1,0,0);
			me["AI_banklimit_R"].setColor(1,0,0);
		} else if (Value.Ai.alpha >= pts.Fdm.JSBsim.Fcc.stallWarnAlphaDeg.getValue() and Value.Misc.slatsPos >= 0.1) {
			me["AI_PLI"].setColor(0.9647,0.8196,0.0784);
			me["AI_banklimit_L"].setColor(1,1,1);
			me["AI_banklimit_R"].setColor(1,1,1);
		} else {
			me["AI_PLI"].setColor(0.3412,0.7882,0.9922);
			me["AI_banklimit_L"].setColor(1,1,1);
			me["AI_banklimit_R"].setColor(1,1,1);
		}
		
		if (Value.Ai.pitch > 25) {
			me["AI_arrow_dn"].setRotation(math.clamp(-Value.Ai.roll, -45, 45) * D2R);
			me["AI_arrow_dn"].show();
			me["AI_arrow_up"].hide();
		} else if (Value.Ai.pitch < -15) {
			me["AI_arrow_up"].setRotation(math.clamp(-Value.Ai.roll, -45, 45) * D2R);
			me["AI_arrow_dn"].hide();
			me["AI_arrow_up"].show();
		} else {
			me["AI_arrow_dn"].hide();
			me["AI_arrow_up"].hide();
		}
		
		me["FD_pitch"].setTranslation(0, afs.Fd.pitchBar.getValue() * -10.246);
		me["FD_roll"].setTranslation(afs.Fd.rollBar.getValue() * 2.2, 0);
		
		# ALT
		Value.Alt.indicated = pts.Instrumentation.Altimeter.indicatedAltitudeFt.getValue();
		Value.Alt.Tape.offset = Value.Alt.indicated / 500 - int(Value.Alt.indicated / 500);
		Value.Alt.Tape.middleText = roundAboutAlt(Value.Alt.indicated / 100) * 100;
		Value.Alt.Tape.middleOffset = nil;
		
		if (Value.Alt.Tape.offset > 0.5) {
			Value.Alt.Tape.middleOffset = -(Value.Alt.Tape.offset - 1) * 254.508;
		} else {
			Value.Alt.Tape.middleOffset = -Value.Alt.Tape.offset * 254.508;
		}
		
		me["ALT_scale"].setTranslation(0, -Value.Alt.Tape.middleOffset);
		me["ALT_scale_num"].setTranslation(0, -Value.Alt.Tape.middleOffset);
		me["ALT_scale"].update();
		me["ALT_scale_num"].update();
		
		Value.Alt.Tape.five = int((Value.Alt.Tape.middleText + 1000) * 0.001);
		me["ALT_five"].setText(sprintf("%03d", abs(1000 * (((Value.Alt.Tape.middleText + 1000) * 0.001) - Value.Alt.Tape.five))));
		Value.Alt.Tape.fiveT = sprintf("%01d", abs(Value.Alt.Tape.five));
		
		if (Value.Alt.Tape.fiveT == 0) {
			me["ALT_five_T"].setText("");
		} else {
			me["ALT_five_T"].setText(Value.Alt.Tape.fiveT);
		}
		
		Value.Alt.Tape.four = int((Value.Alt.Tape.middleText + 500) * 0.001);
		me["ALT_four"].setText(sprintf("%03d", abs(1000 * (((Value.Alt.Tape.middleText + 500) * 0.001) - Value.Alt.Tape.four))));
		Value.Alt.Tape.fourT = sprintf("%01d", abs(Value.Alt.Tape.four));
		
		if (Value.Alt.Tape.fourT == 0) {
			me["ALT_four_T"].setText("");
		} else {
			me["ALT_four_T"].setText(Value.Alt.Tape.fourT);
		}
		
		Value.Alt.Tape.three = int(Value.Alt.Tape.middleText * 0.001);
		me["ALT_three"].setText(sprintf("%03d", abs(1000 * ((Value.Alt.Tape.middleText  * 0.001) - Value.Alt.Tape.three))));
		Value.Alt.Tape.threeT = sprintf("%01d", abs(Value.Alt.Tape.three));
		
		if (Value.Alt.Tape.threeT == 0) {
			me["ALT_three_T"].setText("");
		} else {
			me["ALT_three_T"].setText(Value.Alt.Tape.threeT);
		}
		
		Value.Alt.Tape.two = int((Value.Alt.Tape.middleText - 500) * 0.001);
		me["ALT_two"].setText(sprintf("%03d", abs(1000 * (((Value.Alt.Tape.middleText - 500) * 0.001) - Value.Alt.Tape.two))));
		Value.Alt.Tape.twoT = sprintf("%01d", abs(Value.Alt.Tape.two));
		
		if (Value.Alt.Tape.twoT == 0) {
			me["ALT_two_T"].setText("");
		} else {
			me["ALT_two_T"].setText(Value.Alt.Tape.twoT);
		}
		
		Value.Alt.Tape.one = int((Value.Alt.Tape.middleText - 1000) * 0.001);
		me["ALT_one"].setText(sprintf("%03d", abs(1000 * (((Value.Alt.Tape.middleText - 1000) * 0.001) - Value.Alt.Tape.one))));
		Value.Alt.Tape.oneT = sprintf("%01d", abs(Value.Alt.Tape.one));
		
		if (Value.Alt.Tape.oneT == 0) {
			me["ALT_one_T"].setText("");
		} else {
			me["ALT_one_T"].setText(Value.Alt.Tape.oneT);
		}
		
		if (Value.Alt.indicated < 0) {
			if (Value.Alt.indicated < -9980) {
				me["ALT_minus"].setTranslation(-22.172, 0);
			} else if (Value.Alt.indicated >= -980) {
				me["ALT_minus"].setTranslation(22.172, 0);
			} else {
				me["ALT_minus"].setTranslation(0, 0);
			}
			me["ALT_minus"].show();
		} else {
			me["ALT_minus"].hide();
		}
		
		Value.Alt.indicatedAbs = abs(Value.Alt.indicated);
		
		if (Value.Alt.indicatedAbs < 9900) { # Prepare to show the zero at 10000
			me["ALT_thousands_zero"].hide();
		} else {
			me["ALT_thousands_zero"].show();
		}
		
		Value.Alt.Tape.tenThousands = num(right(sprintf("%05d", Value.Alt.indicatedAbs), 5)) / 100; # Unlikely it would be above 99999 but lets account for it anyways
		Value.Alt.Tape.tenThousandsGeneva = genevaAltTenThousands(Value.Alt.Tape.tenThousands);
		me["ALT_tenthousands"].setTranslation(0, Value.Alt.Tape.tenThousandsGeneva * 42.65);
		
		Value.Alt.Tape.thousands = num(right(sprintf("%04d", Value.Alt.indicatedAbs), 4)) / 100;
		Value.Alt.Tape.thousandsGeneva = genevaAltThousands(Value.Alt.Tape.thousands);
		me["ALT_thousands"].setTranslation(0, Value.Alt.Tape.thousandsGeneva * 42.65);
		
		Value.Alt.Tape.hundreds = num(right(sprintf("%03d", Value.Alt.indicatedAbs), 3)) / 100;
		Value.Alt.Tape.hundredsGeneva = genevaAltHundreds(Value.Alt.Tape.hundreds);
		me["ALT_hundreds"].setTranslation(0, Value.Alt.Tape.hundredsGeneva * 42.65);
		
		Value.Alt.Tape.tens = num(right(sprintf("%02d", Value.Alt.indicatedAbs), 2));
		me["ALT_tens"].setTranslation(0, Value.Alt.Tape.tens * 2.1325);
		
		Value.Alt.alert = systems.WARNINGS.altitudeAlert.getValue();
		if (Value.Alt.alert == 1 or (Value.Alt.alert == 2 and Value.Misc.blinkMed)) {
			me["ALT_bowtie"].setColor(0.9412,0.7255,0);
		} else {
			me["ALT_bowtie"].setColor(1,1,1);
		}
		
		# ALT Pre-Sel/Sel
		Value.Afs.alt = afs.Internal.alt.getValue();
		Value.Afs.altSel = afs.Input.alt.getValue();
		Value.Alt.preSel = pts.Instrumentation.Pfd.altPreSel.getValue();
		Value.Alt.sel = pts.Instrumentation.Pfd.altSel.getValue();
		
		me["ALT_presel"].setTranslation(0, (Value.Alt.preSel / 100) * -50.9016);
		me["ALT_sel"].setTranslation(0, (Value.Alt.sel / 100) * -50.9016);
		
		if (Value.Alt.preSel < -525 or Value.Alt.preSel > 525 or afs.Internal.syncedAlt) {
			me["ALT_presel"].hide();
		} else  {
			me["ALT_presel"].show();
		}
		if (Value.Alt.sel < -525 or Value.Alt.sel > 525) {
			me["ALT_sel"].hide();
		} else  {
			me["ALT_sel"].show();
		}
		
		if (Value.Alt.preSel > 525 and !afs.Internal.syncedAlt) {
			me["ALT_sel_up"].setColorFill(0,0,0);
			me["ALT_sel_up"].show();
			me["ALT_sel_up_text"].setText(right(sprintf("%03d", Value.Afs.altSel), 3));
			me["ALT_sel_up_text"].show();
			if (Value.Afs.altSel < 1000) {
				me["ALT_sel_up_text_T"].hide();
			} else {
				me["ALT_sel_up_text_T"].setText(sprintf("%2.0f", math.floor(Value.Afs.altSel / 1000)));
				me["ALT_sel_up_text_T"].show();
			}
		} else if (Value.Alt.sel > 525) {
			me["ALT_sel_up"].setColorFill(1,1,1);
			me["ALT_sel_up"].show();
			me["ALT_sel_up_text"].setText(right(sprintf("%03d", Value.Afs.alt), 3));
			me["ALT_sel_up_text"].show();
			if (Value.Afs.alt < 1000) {
				me["ALT_sel_up_text_T"].hide();
			} else {
				me["ALT_sel_up_text_T"].setText(sprintf("%2.0f", math.floor(Value.Afs.alt / 1000)));
				me["ALT_sel_up_text_T"].show();
			}
		} else {
			me["ALT_sel_up"].hide();
			me["ALT_sel_up_text"].hide();
			me["ALT_sel_up_text_T"].hide();
		}
		
		if (Value.Alt.preSel < -525 and !afs.Internal.syncedAlt) {
			me["ALT_sel_dn"].setColorFill(0,0,0);
			me["ALT_sel_dn"].show();
			me["ALT_sel_dn_text"].setText(right(sprintf("%03d", Value.Afs.altSel), 3));
			me["ALT_sel_dn_text"].show();
			if (Value.Afs.altSel < 1000) {
				me["ALT_sel_dn_text_T"].hide();
			} else {
				me["ALT_sel_dn_text_T"].setText(sprintf("%2.0f", math.floor(Value.Afs.altSel / 1000)));
				me["ALT_sel_dn_text_T"].show();
			}
		} else if (Value.Alt.sel < -525) {
			me["ALT_sel_dn"].setColorFill(1,1,1);
			me["ALT_sel_dn"].show();
			me["ALT_sel_dn_text"].setText(right(sprintf("%03d", Value.Afs.alt), 3));
			me["ALT_sel_dn_text"].show();
			if (Value.Afs.alt < 1000) {
				me["ALT_sel_dn_text_T"].hide();
			} else {
				me["ALT_sel_dn_text_T"].setText(sprintf("%2.0f", math.floor(Value.Afs.alt / 1000)));
				me["ALT_sel_dn_text_T"].show();
			}
		} else {
			me["ALT_sel_dn"].hide();
			me["ALT_sel_dn_text"].hide();
			me["ALT_sel_dn_text_T"].hide();
		}
		
		Value.Ra.agl = pts.Position.gearAglFt.getValue();
		me["ALT_agl"].setTranslation(0, (math.clamp(Value.Ra.agl, -700, 700) / 100) * 50.9016);
		
		# VS
		Value.Vs.digit = pts.Instrumentation.Pfd.vsDigit.getValue();
		Value.Vs.indicated = afs.Internal.vs.getValue();
		
		if (Value.Vs.indicated > 100) {
			me["VSI_needle_up"].setTranslation(0, pts.Instrumentation.Pfd.vsNeedleUp.getValue());
			me["VSI_needle_up"].show();
			if (Value.Vs.digit > 0) {
				me["VSI_up"].setText(sprintf("%1.1f", Value.Vs.digit));
				me["VSI_up"].show();
			} else {
				me["VSI_up"].hide();
			}
		} else if (Value.Vs.indicated < 50) {
			me["VSI_needle_up"].hide();
			me["VSI_up"].hide();
		}
		if (Value.Vs.indicated < -100) {
			me["VSI_needle_dn"].setTranslation(0, pts.Instrumentation.Pfd.vsNeedleDn.getValue());
			me["VSI_needle_dn"].show();
			if (Value.Vs.digit > 0) {
				me["VSI_dn"].setText(sprintf("%1.1f", Value.Vs.digit));
				me["VSI_dn"].show();
			} else {
				me["VSI_dn"].hide();
			}
		} else if (Value.Vs.indicated > -50) {
			me["VSI_needle_dn"].hide();
			me["VSI_dn"].hide();
		}
		
		Value.Afs.vs = afs.Input.vs.getValue();
		if (Value.Afs.vert == 1) {
			if (Value.Afs.vs >= 50) {
				me["VSI_bug_dn"].hide();
				me["VSI_bug_up"].setTranslation(0, pts.Instrumentation.Pfd.vsBugUp.getValue());
				me["VSI_bug_up"].show();
			} else if (Value.Afs.vs <= -50) {
				me["VSI_bug_dn"].setTranslation(0, pts.Instrumentation.Pfd.vsBugDn.getValue());
				me["VSI_bug_dn"].show();
				me["VSI_bug_up"].hide();
			} else {
				me["VSI_bug_up"].hide();
				me["VSI_bug_dn"].hide();
			}
		} else {
			me["VSI_bug_up"].hide();
			me["VSI_bug_dn"].hide();
		}
		
		# ILS
		Value.Nav.headingNeedleDeflectionNorm = pts.Instrumentation.Nav.headingNeedleDeflectionNorm[2].getValue();
		Value.Nav.selectedMhz = pts.Instrumentation.Nav.Frequencies.selectedMhz[2].getValue();
		Value.Nav.signalQuality = pts.Instrumentation.Nav.signalQualityNorm[2].getValue();
		if (Value.Nav.selectedMhz != 0) {
			if (pts.Instrumentation.Nav.navLoc[2].getBoolValue() and Value.Nav.signalQuality > 0.99) {
				me["LOC_no"].hide();
				
				if (Value.Ra.agl <= 300 and !Value.Misc.wow and (Value.Afs.roll == "LOC" or Value.Afs.roll == "ALIGN") and abs(Value.Nav.headingNeedleDeflectionNorm) > 0.105) { # 1/4 Dot
					me["LOC_pointer"].setColor(0.9647,0.8196,0.0784);
					
					if (Value.Misc.blinkMed) {
						me["AI_rising_runway"].setTranslation(Value.Nav.headingNeedleDeflectionNorm * 105, math.clamp(Value.Ra.agl, 0, 200) * 1.17); # Laterally aligned to edge of AI sphere
						me["AI_rising_runway"].show();
						me["LOC_pointer"].setTranslation(Value.Nav.headingNeedleDeflectionNorm * 200, 0);
						me["LOC_pointer"].show();
					} else {
						me["AI_rising_runway"].hide();
						me["LOC_pointer"].hide();
					}
				} else {
					me["AI_rising_runway"].setTranslation(Value.Nav.headingNeedleDeflectionNorm * 105, Value.Ra.agl * 1.17); # Laterally aligned to edge of AI sphere
					me["AI_rising_runway"].show();
					me["LOC_pointer"].setColor(0.9607,0,0.7764);
					me["LOC_pointer"].setTranslation(Value.Nav.headingNeedleDeflectionNorm * 200, 0);
					me["LOC_pointer"].show();
				}
			} else {
				me["AI_rising_runway"].hide();
				me["LOC_no"].show();
				me["LOC_pointer"].hide();
			}
			
			me["LOC_scale"].show();
		} else {
			me["AI_rising_runway"].hide();
			me["LOC_no"].hide();
			me["LOC_pointer"].hide();
			me["LOC_scale"].hide();
		}
		
		Value.Nav.gsNeedleDeflectionNorm = pts.Instrumentation.Nav.gsNeedleDeflectionNorm[2].getValue();
		Value.Nav.gsInRange = pts.Instrumentation.Nav.gsInRange[2].getBoolValue();
		if (Value.Nav.selectedMhz != 0) {
			if (Value.Nav.gsInRange and pts.Instrumentation.Nav.hasGs[2].getBoolValue() and Value.Nav.signalQuality > 0.99) {
				me["GS_no"].hide();
				
				if (Value.Ra.agl >= 100 and Value.Ra.agl <= 500 and Value.Afs.pitch == "G/S" and abs(Value.Nav.gsNeedleDeflectionNorm) > 0.41) { # One Dot
					me["GS_pointer"].setColor(0.9647,0.8196,0.0784);
					
					if (Value.Misc.blinkMed) {
						me["GS_pointer"].setTranslation(0, Value.Nav.gsNeedleDeflectionNorm * -204);
						me["GS_pointer"].show();
					} else {
						me["GS_pointer"].hide();
					}
				} else {
					me["GS_pointer"].setColor(0.9607,0,0.7764);
					me["GS_pointer"].setTranslation(0, Value.Nav.gsNeedleDeflectionNorm * -204);
					me["GS_pointer"].show();
				}
			} else {
				me["GS_no"].show();
				me["GS_pointer"].hide();
			}
			me["GS_scale"].show();
		} else {
			me["GS_no"].hide();
			me["GS_pointer"].hide();
			me["GS_scale"].hide();
		}
		
		# ILS DME
		if (Value.Nav.selectedMhz != 0) {
			if (Value.Nav.signalQuality > 0.99) {
				if (pts.Instrumentation.Dme.inRange[2].getBoolValue()) {
					me["ILS_DME"].setText(sprintf("%3.1f", math.round(pts.Instrumentation.Dme.indicatedDistanceNm[2].getValue(), 0.1)));
					me["ILS_DME"].show();
				} else {
					me["ILS_DME"].hide();
				}
				me["ILS_Info"].setText(pts.Instrumentation.Nav.navId[2].getValue());
				me["ILS_Info"].show();
			} else {
				me["ILS_DME"].hide();
				me["ILS_Info"].setText(sprintf("%6.2f", pts.Instrumentation.Nav.Frequencies.selectedMhz[2].getValue()));
				me["ILS_Info"].show();
			}
		} else {
			me["ILS_DME"].hide();
			me["ILS_Info"].hide();
		}
		
		# Marker Beacons
		if (pts.Instrumentation.MarkerBeacon.inner.getBoolValue()) {
			me["Inner_Marker"].show();
			me["Middle_Marker"].hide();
			me["Outer_Marker"].hide();
		} else if (pts.Instrumentation.MarkerBeacon.middle.getBoolValue()) {
			me["Inner_Marker"].hide();
			me["Middle_Marker"].show();
			me["Outer_Marker"].hide();
		} else if (pts.Instrumentation.MarkerBeacon.outer.getBoolValue()) {
			me["Inner_Marker"].hide();
			me["Middle_Marker"].hide();
			me["Outer_Marker"].show();
		} else {
			me["Inner_Marker"].hide();
			me["Middle_Marker"].hide();
			me["Outer_Marker"].hide();
		}
		
		# RA and Minimums
		Value.Misc.minimums = pts.Controls.Switches.minimums.getValue();
		
		if (Value.Ra.agl <= 2500) {
			if (Value.Ra.agl <= Value.Misc.minimums) {
				me["Minimums"].setColor(0.9412,0.7255,0);
				me["RA"].setColor(0.9412,0.7255,0);
				me["RA_box"].setColor(0.9412,0.7255,0);
			} else {
				me["Minimums"].setColor(1,1,1);
				me["RA"].setColor(1,1,1);
				me["RA_box"].setColor(1,1,1);
			}
			if (Value.Ra.agl <= 5) {
				me["RA"].setText(sprintf("%4.0f", math.round(Value.Ra.agl)));
			} else if (Value.Ra.agl <= 50) {
				me["RA"].setText(sprintf("%4.0f", math.round(Value.Ra.agl, 5)));
			} else {
				me["RA"].setText(sprintf("%4.0f", math.round(Value.Ra.agl, 10)));
			}
			me["RA"].show();
			me["RA_box"].show();
		} else {
			me["RA"].hide();
			me["RA_box"].hide();
		}
		
		# HDG
		if (pts.Instrumentation.Efis.Mfd.trueNorth[n].getBoolValue()) {
			me["HDG_magtru"].setColor(0.3412,0.7882,0.9922);
			me["HDG_magtru"].setText("TRU");
		} else {
			me["HDG_magtru"].setColor(1,1,1);
			me["HDG_magtru"].setText("MAG");
		}
		
		Value.Hdg.indicated = pts.Instrumentation.Pfd.hdgDeg[n].getValue();
		Value.Hdg.indicatedFixed = Value.Hdg.indicated + 0.5;
		
		if (Value.Hdg.indicatedFixed > 359) {
			Value.Hdg.indicatedFixed = Value.Hdg.indicatedFixed - 360;
		}
		if (Value.Hdg.indicatedFixed < 0) {
			Value.Hdg.indicatedFixed = Value.Hdg.indicatedFixed + 360;
		}
		Value.Hdg.text = sprintf("%03d", Value.Hdg.indicatedFixed);
		
		if (Value.Hdg.text == "360") {
			Value.Hdg.text == "000";
		}
		me["HDG"].setText(Value.Hdg.text);
		me["HDG_dial"].setRotation(Value.Hdg.indicated * -D2R);
		
		Value.Hdg.preSel = pts.Instrumentation.Pfd.hdgPreSel.getValue();
		Value.Hdg.sel = pts.Instrumentation.Pfd.hdgSel.getValue();
		Value.Hdg.showHdg = afs.Output.showHdg.getBoolValue();
		
		if (Value.Hdg.preSel <= 35 and Value.Hdg.preSel >= -35) {
			Value.Hdg.Tape.preSel = Value.Hdg.preSel;
		} else if (Value.Hdg.preSel > 35) {
			Value.Hdg.Tape.preSel = 35;
		} else if (Value.Hdg.preSel < -35) {
			Value.Hdg.Tape.preSel = -35;
		}
		if (Value.Hdg.sel <= 35 and Value.Hdg.sel >= -35) {
			Value.Hdg.Tape.sel = Value.Hdg.sel;
		} else if (Value.Hdg.sel > 35) {
			Value.Hdg.Tape.sel = 35;
		} else if (Value.Hdg.sel < -35) {
			Value.Hdg.Tape.sel = -35;
		}
		
		if (Value.Hdg.showHdg) {
			if (Value.Afs.lat == 0 and afs.Internal.syncedHdg) {
				me["HDG_presel"].hide();
			} else {
				me["HDG_presel"].setRotation(Value.Hdg.Tape.preSel * D2R);
				me["HDG_presel"].show();
			}
			
			if (Value.Hdg.preSel < -35 and !afs.Internal.syncedHdg) {
				me["HDG_sel_left_text"].setText(right(sprintf("%03d", Value.Afs.hdgSel), 3));
				me["HDG_sel_left_text"].show();
			} else if (Value.Hdg.sel < -35 and Value.Afs.lat == 0) {
				me["HDG_sel_left_text"].setText(right(sprintf("%03d", Value.Afs.hdg), 3));
				me["HDG_sel_left_text"].show();
			} else {
				me["HDG_sel_left_text"].hide();
			}
		
			if (Value.Hdg.preSel > 35 and !afs.Internal.syncedHdg) {
				me["HDG_sel_right_text"].setText(right(sprintf("%03d", Value.Afs.hdgSel), 3));
				me["HDG_sel_right_text"].show();
			} else if (Value.Hdg.sel > 35 and Value.Afs.lat == 0) {
				me["HDG_sel_right_text"].setText(right(sprintf("%03d", Value.Afs.hdg), 3));
				me["HDG_sel_right_text"].show();
			} else {
				me["HDG_sel_right_text"].hide();
			}
			
			if (!afs.Internal.syncedHdg) {
				if (Value.Hdg.preSel < -35 and Value.Hdg.sel < -35) {
					Value.Hdg.hideHdgSel = 1;
				} else if (Value.Hdg.preSel > 35 and Value.Hdg.sel > 35) {
					Value.Hdg.hideHdgSel = 1;
				} else {
					Value.Hdg.hideHdgSel = 0;
				}
			} else {
				Value.Hdg.hideHdgSel = 0;
			}
			
			if (Value.Afs.lat == 0 and !Value.Hdg.hideHdgSel) {
				me["HDG_sel"].setRotation(Value.Hdg.Tape.sel * D2R);
				me["HDG_sel"].show();
			} else {
				me["HDG_sel"].hide();
			}
		} else {
			me["HDG_presel"].hide();
			me["HDG_sel"].hide();
			me["HDG_sel_left_text"].hide();
			me["HDG_sel_right_text"].hide();
		}
		
		if (!Value.Misc.wow) {
			me["TRK_pointer"].setRotation(Value.Hdg.track * D2R);
			me["TRK_pointer"].show();
		} else {
			me["TRK_pointer"].hide();
		}
		
		# FMA
		Value.Afs.spdProt = afs.Output.spdProt.getValue();
		if (Value.Afs.ats and Value.Afs.spdProt != 0) {
			if (Value.Misc.blinkMed) {
				if (Value.Afs.spdProt == 2) {
					me["FMA_Thrust_Arm"].setText("HI SPEED");
				} else {
					me["FMA_Thrust_Arm"].setText("LO SPEED");
				}
			} else {
				me["FMA_Thrust_Arm"].setText("PROTECTION");
			}
		} else {
			me["FMA_Thrust_Arm"].setText("");
		}
		
		me["FMA_Pitch_Arm"].setText(sprintf("%s", Value.Afs.pitchArm));
		me["FMA_Roll_Arm"].setText(sprintf("%s", Value.Afs.rollArm));
		
		if (Value.Afs.land == "DUAL") {
			me["FMA_Roll"].setColor(0,1,0);
		} else if (Value.Afs.roll == "NAV1" or Value.Afs.roll == "NAV2") {
			me["FMA_Roll"].setColor(0.9607,0,0.7764);
		} else {
			me["FMA_Roll"].setColor(1,1,1);
		}
		
		if (Value.Afs.rollArm == "NAV ARMED") {
			me["FMA_Roll_Arm"].setColor(0.9607,0,0.7764);
		} else {
			me["FMA_Roll_Arm"].setColor(1,1,1);
		}
		
		if (Value.Afs.land == "DUAL") {
			me["FMA_Altitude"].hide();
			me["FMA_Altitude_Thousand"].hide();
			me["FMA_Land"].setColor(0,1,0);
			me["FMA_Land"].setText("DUAL LAND");
			me["FMA_Land"].show();
			me["FMA_Pitch_Land"].setColor(0,1,0);
			me["FMA_Pitch_Land"].setText(sprintf("%s", Value.Afs.pitch));
			me["FMA_Pitch_Land"].show();
		} else if (Value.Afs.land == "SINGLE") {
			me["FMA_Altitude"].hide();
			me["FMA_Altitude_Thousand"].hide();
			me["FMA_Land"].setColor(1,1,1);
			me["FMA_Land"].setText("SINGLE LAND");
			me["FMA_Land"].show();
			me["FMA_Pitch_Land"].setColor(1,1,1);
			me["FMA_Pitch_Land"].setText(sprintf("%s", Value.Afs.pitch));
			me["FMA_Pitch_Land"].show();
		} else if (Value.Afs.land == "APPR") {
			me["FMA_Altitude"].hide();
			me["FMA_Altitude_Thousand"].hide();
			me["FMA_Land"].setColor(1,1,1);
			me["FMA_Land"].setText("APPR ONLY");
			me["FMA_Land"].show();
			me["FMA_Pitch_Land"].setColor(1,1,1);
			me["FMA_Pitch_Land"].setText(sprintf("%s", Value.Afs.pitch));
			me["FMA_Pitch_Land"].show();
		} else {
			me["FMA_Altitude"].setText(right(sprintf("%03d", Value.Afs.alt), 3));
			me["FMA_Altitude"].show();
			if (Value.Afs.alt < 1000) {
				me["FMA_Altitude_Thousand"].hide();
			} else {
				me["FMA_Altitude_Thousand"].setText(sprintf("%2.0f", math.floor(Value.Afs.alt / 1000)));
				me["FMA_Altitude_Thousand"].show();
			}
			me["FMA_Land"].hide();
			me["FMA_Pitch_Land"].hide();
		}
		
		if (Value.Afs.pitch == "ROLLOUT") {
			me["FMA_Pitch_Land"].setTranslation(-10, 0);
		} else {
			me["FMA_Pitch_Land"].setTranslation(0, 0);
		}
		
		if (Value.Afs.thrust == "RETARD") {
			me["FMA_Speed"].hide();
		} else {
			if (Value.Afs.ktsMach) {
				me["FMA_Speed"].setText("." ~ sprintf("%3.0f", Value.Afs.mach * 1000));
			} else {
				me["FMA_Speed"].setText(sprintf("%3.0f", Value.Afs.kts));
			}
			me["FMA_Speed"].show();
		}
		
		Value.Afs.apDisc[0] = pts.Controls.Cockpit.apDisc[0].getBoolValue();
		Value.Afs.apDisc[1] = pts.Controls.Cockpit.apDisc[1].getBoolValue();
		Value.Afs.ap1Avail = afs.Input.ap1Avail.getBoolValue();
		Value.Afs.ap2Avail = afs.Input.ap2Avail.getBoolValue();
		Value.Afs.apSound = afs.Sound.apOff.getBoolValue();
		Value.Afs.apWarn = afs.Warning.ap.getBoolValue();
		Value.Afs.atsFlash = afs.Warning.atsFlash.getBoolValue();
		Value.Afs.atsWarn = afs.Warning.ats.getBoolValue();
		
		if (Value.Afs.atsFlash) {
			me["FMA_ATS_Pitch_Off"].setColor(1,0,0);
			me["FMA_ATS_Thrust_Off"].setColor(1,0,0);
		} else if (!afs.Input.athrAvail.getBoolValue()) {
			me["FMA_ATS_Pitch_Off"].setColor(0.9412,0.7255,0);
			me["FMA_ATS_Thrust_Off"].setColor(0.9412,0.7255,0);
		} else {
			me["FMA_ATS_Pitch_Off"].setColor(1,1,1);
			me["FMA_ATS_Thrust_Off"].setColor(1,1,1);
		}
		
		if (Value.Afs.apSound) {
			me["FMA_AP_Pitch_Off_Box"].setColor(1,0,0);
			me["FMA_AP_Thrust_Off_Box"].setColor(1,0,0);
		} else if (!Value.Afs.ap1Avail and !Value.Afs.ap2Avail) {
			me["FMA_AP_Pitch_Off_Box"].setColor(0.9412,0.7255,0);
			me["FMA_AP_Thrust_Off_Box"].setColor(0.9412,0.7255,0);
		} else if ((Value.Afs.apDisc[0] or Value.Afs.apDisc[1]) and !Value.Afs.ap1 and !Value.Afs.ap2) {
			me["FMA_AP_Pitch_Off_Box"].setColor(0.9412,0.7255,0);
			me["FMA_AP_Thrust_Off_Box"].setColor(0.9412,0.7255,0);
		} else {
			me["FMA_AP_Pitch_Off_Box"].setColor(1,1,1);
			me["FMA_AP_Thrust_Off_Box"].setColor(1,1,1);
		}
		
		if (Value.Afs.ats == 1) {
			if (Value.Afs.spdProt != 0 and Value.Afs.thrust == "PITCH") {
				if (Value.Misc.blinkMed2) {
					me["FMA_ATS_Pitch_Off"].show();
				} else {
					me["FMA_ATS_Pitch_Off"].hide();
				}
				me["FMA_ATS_Thrust_Off"].hide();
			} else if (Value.Afs.spdProt != 0) {
				me["FMA_ATS_Pitch_Off"].hide();
				if (Value.Misc.blinkMed2) {
					me["FMA_ATS_Thrust_Off"].show();
				} else {
					me["FMA_ATS_Thrust_Off"].hide();
				}
			} else {
				me["FMA_ATS_Pitch_Off"].hide();
				me["FMA_ATS_Thrust_Off"].hide();
			}
		} else if (Value.Afs.atsFlash and !Value.Afs.atsWarn) {
			me["FMA_ATS_Pitch_Off"].hide();
			me["FMA_ATS_Thrust_Off"].hide();
		} else if (Value.Afs.atsFlash and Value.Afs.atsWarn and Value.Afs.thrust == "PITCH") {
			me["FMA_ATS_Pitch_Off"].show();
			me["FMA_ATS_Thrust_Off"].hide();
		} else if (Value.Afs.atsFlash and Value.Afs.atsWarn and Value.Afs.thrust != "PITCH") {
			me["FMA_ATS_Pitch_Off"].hide();
			me["FMA_ATS_Thrust_Off"].show();
		} else if (Value.Afs.thrust == "PITCH") {
			me["FMA_ATS_Pitch_Off"].show();
			me["FMA_ATS_Thrust_Off"].hide();
		} else {
			me["FMA_ATS_Pitch_Off"].hide();
			me["FMA_ATS_Thrust_Off"].show();
		}
		
		if (Value.Afs.ap1 or Value.Afs.ap2) {
			me["FMA_AP"].setColor(0.3215,0.8078,1);
			if (Value.Afs.land == "DUAL") {
				me["FMA_AP"].setText("AP");
			} else if (Value.Afs.ap1) {
				me["FMA_AP"].setText("AP1");
			} else if (Value.Afs.ap2) {
				me["FMA_AP"].setText("AP2");
			}
			me["FMA_AP"].show();
		} else if (Value.Afs.apSound and !Value.Afs.apWarn) {
			me["FMA_AP"].hide();
		} else if (Value.Afs.apSound and Value.Afs.apWarn) {
			me["FMA_AP"].setColor(1,0,0);
			me["FMA_AP"].setText("AP OFF");
			me["FMA_AP"].show();
		} else if (Value.Afs.apDisc[0] or Value.Afs.apDisc[1] or (!Value.Afs.ap1Avail and !Value.Afs.ap2Avail)) {
			me["FMA_AP"].setColor(0.9412,0.7255,0);
			me["FMA_AP"].setText("AP OFF");
			me["FMA_AP"].show();
		} else {
			me["FMA_AP"].setColor(1,1,1);
			me["FMA_AP"].setText("AP OFF");
			me["FMA_AP"].show();
		}
		
		if (Value.Afs.ap1 or Value.Afs.ap2) {
			me["FMA_AP_Pitch_Off_Box"].hide();
			me["FMA_AP_Thrust_Off_Box"].hide();
		} else if (Value.Afs.apSound and !Value.Afs.apWarn) {
			me["FMA_AP_Pitch_Off_Box"].hide();
			me["FMA_AP_Thrust_Off_Box"].hide();
		} else if (Value.Afs.apSound and Value.Afs.apWarn and Value.Afs.thrust == "PITCH") {
			me["FMA_AP_Pitch_Off_Box"].show();
			me["FMA_AP_Thrust_Off_Box"].hide();
		} else if (Value.Afs.apSound and Value.Afs.apWarn and Value.Afs.thrust != "PITCH") {
			me["FMA_AP_Pitch_Off_Box"].hide();
			me["FMA_AP_Thrust_Off_Box"].show();
		} else if (Value.Afs.thrust == "PITCH") {
			me["FMA_AP_Pitch_Off_Box"].show();
			me["FMA_AP_Thrust_Off_Box"].hide();
		} else {
			me["FMA_AP_Pitch_Off_Box"].hide();
			me["FMA_AP_Thrust_Off_Box"].show();
		}
		
		# QNH
		Value.Qnh.inhg = pts.Instrumentation.Altimeter.inhg.getBoolValue();
		if (pts.Instrumentation.Altimeter.std.getBoolValue()) {
			if (Value.Qnh.inhg == 0) {
				me["QNH"].setText("1013");
			} else if (Value.Qnh.inhg == 1) {
				me["QNH"].setText("29.92");
			}
		} else if (Value.Qnh.inhg == 0) {
			me["QNH"].setText(sprintf("%d", pts.Instrumentation.Altimeter.settingHpa.getValue()));
		} else if (Value.Qnh.inhg == 1) {
			me["QNH"].setText(sprintf("%2.2f", pts.Instrumentation.Altimeter.settingInhg.getValue()));
		}
		
		# Minimums
		me["Minimums"].setText(sprintf("%4.0f", Value.Misc.minimums)); # Variable update in updateBase
		
		# Slats/Flaps
		if (Value.Misc.slatsOut and !(Value.Misc.slatsPos >= 30.9 and Value.Misc.flapsOut)) {
			me["Slats"].show();
			if (pts.Controls.Flight.autoSlatTimer.getValue() > 0) {
				me["Slats_auto"].show();
				me["Slats_dn"].hide();
				me["Slats_up"].hide();
			} else if (Value.Misc.slatsCmd - Value.Misc.slatsPos >= 0.1) {
				me["Slats_auto"].hide();
				me["Slats_dn"].show();
				me["Slats_up"].hide();
			} else if (Value.Misc.slatsCmd - Value.Misc.slatsPos <= -0.1) {
				me["Slats_auto"].hide();
				me["Slats_dn"].hide();
				me["Slats_up"].show();
			} else {
				me["Slats_auto"].hide();
				me["Slats_dn"].hide();
				me["Slats_up"].hide();
			}
		} else {
			me["Slats"].hide();
			me["Slats_auto"].hide();
			me["Slats_up"].hide();
			me["Slats_dn"].hide();
		}
		
		if (Value.Misc.flapsOut) {
			me["Flaps"].show();
			me["Flaps_num"].setText(sprintf("%2.0f", Value.Misc.flapsCmd));
			me["Flaps_num"].show();
		} else {
			me["Flaps"].hide();
			me["Flaps_num"].hide();
		}
		
		if (!Value.Misc.slatsOut and pts.Controls.Flight.slatStow.getBoolValue() and pts.Controls.Flight.flapsInput.getValue() >= 1) {
			me["Slats_no"].show();
		} else {
			me["Slats_no"].hide();
		}
		
		if (Value.Misc.flapsOut and Value.Misc.flapsCmd - 0.1 >= pts.Fdm.JSBsim.Fcc.Flap.maxDeg.getValue()) {
			me["Flaps_dn"].hide();
			me["Flaps_up"].hide();
			me["Flaps_num"].setColor(0.9647,0.8196,0.0784);
			me["Flaps_num_boxes"].show();
			me["Flaps_num2"].setText(sprintf("%2.0f", Value.Misc.flapsCmd));
			me["Flaps_num2"].show();
		} else {
			if (Value.Misc.flapsCmd - Value.Misc.flapsPos >= 0.1) {
				me["Flaps_dn"].show();
				me["Flaps_up"].hide();
			} else if (Value.Misc.flapsCmd - Value.Misc.flapsPos <= -0.1) {
				me["Flaps_dn"].hide();
				me["Flaps_up"].show();
			} else {
				me["Flaps_dn"].hide();
				me["Flaps_up"].hide();
			}
			me["Flaps_num"].setColor(1,1,1);
			me["Flaps_num_boxes"].hide();
			me["Flaps_num2"].hide();
		}
		
		# Warnings
		if (Value.Iru.mainAvail[0] or Value.Iru.mainAvail[1] or Value.Iru.mainAvail[2]) {
			me["TCAS_fail"].hide();
			if (instruments.XPDR.tcasMode.getValue() >= 2) {
				me["TCAS_off"].hide();
			} else {
				me["TCAS_off"].show();
			}
		} else {
			me["TCAS_fail"].show();
			me["TCAS_off"].hide();
		}
	},
};

var canvasPfd1 = {
	new: func(canvasGroup, file) {
		var m = {parents: [canvasPfd1, canvasBase]};
		m.init(canvasGroup, file);
		
		return m;
	},
	update: func() {
		# Provide the value to here and the base
		Value.Afs.ap1 = afs.Output.ap1.getBoolValue();
		Value.Afs.ap2 = afs.Output.ap2.getBoolValue();
		Value.Afs.ats = afs.Output.athr.getBoolValue();
		Value.Afs.fd1 = afs.Output.fd1.getBoolValue();
		Value.Afs.hdg = afs.Internal.hdg.getValue();
		Value.Afs.land = afs.Text.land.getValue();
		Value.Afs.pitch = afs.Fma.pitch.getValue();
		Value.Afs.pitchArm = afs.Fma.pitchArm.getValue();
		Value.Afs.roll = afs.Fma.roll.getValue();
		Value.Afs.rollArm = afs.Fma.rollArm.getValue();
		Value.Afs.thrust = afs.Text.spd.getValue();
		Value.Iru.aligned[0] = systems.IRS.Iru.aligned[0].getBoolValue();
		Value.Iru.aligned[1] = systems.IRS.Iru.aligned[1].getBoolValue();
		Value.Iru.aligned[2] = systems.IRS.Iru.aligned[2].getBoolValue();
		Value.Iru.aligning[0] = systems.IRS.Iru.aligning[0].getBoolValue();
		Value.Iru.aligning[1] = systems.IRS.Iru.aligning[1].getBoolValue();
		Value.Iru.aligning[2] = systems.IRS.Iru.aligning[2].getBoolValue();
		Value.Iru.mainAvail[0] = systems.IRS.Iru.mainAvail[0].getBoolValue();
		Value.Iru.mainAvail[1] = systems.IRS.Iru.mainAvail[1].getBoolValue();
		Value.Iru.mainAvail[2] = systems.IRS.Iru.mainAvail[2].getBoolValue();
		
		# FMA
		if (find("CLAMP", Value.Afs.pitch) != -1) {
			Value.Afs.pitch = Value.Afs.pitch ~ " ";
		}
		
		if (Value.Afs.fd1) {
			if (Value.Afs.land == "OFF") {
				me["FMA_Pitch"].setText(sprintf("%s", Value.Afs.pitch));
				me["FMA_Pitch"].show();
			} else {
				me["FMA_Pitch"].hide();
			}
			if (Value.Afs.roll == "HEADING" or Value.Afs.roll == "TRACK") {
				me["FMA_Roll"].setText(sprintf("%s", Value.Afs.roll ~ " " ~ sprintf("%03d", Value.Afs.hdg)));
			} else {
				me["FMA_Roll"].setText(sprintf("%s", Value.Afs.roll));
			}
			me["FMA_Roll"].show();
			me["FMA_Thrust"].setText(sprintf("%s", Value.Afs.thrust));
			me["FMA_Thrust"].show();
		} else {
			if (Value.Afs.thrust == "PITCH") {
				if (Value.Afs.ap1 or Value.Afs.ap2) {
					me["FMA_Thrust"].setText(sprintf("%s", Value.Afs.thrust));
					me["FMA_Thrust"].show();
				} else {
					me["FMA_Thrust"].hide();
				}
				if (Value.Afs.ats and Value.Afs.land == "OFF") {
					me["FMA_Pitch"].setText(sprintf("%s", Value.Afs.pitch));
					me["FMA_Pitch"].show();
				} else {
					me["FMA_Pitch"].hide();
				}
			} else {
				if ((Value.Afs.ap1 or Value.Afs.ap2) and Value.Afs.land == "OFF") {
					me["FMA_Pitch"].setText(sprintf("%s", Value.Afs.pitch));
					me["FMA_Pitch"].show();
				} else {
					me["FMA_Pitch"].hide();
				}
				if (Value.Afs.ats) {
					me["FMA_Thrust"].setText(sprintf("%s", Value.Afs.thrust));
					me["FMA_Thrust"].show();
				} else {
					me["FMA_Thrust"].hide();
				}
			}
			
			if (Value.Afs.ap1 or Value.Afs.ap2) {
				if (Value.Afs.roll == "HEADING" or Value.Afs.roll == "TRACK") {
					me["FMA_Roll"].setText(sprintf("%s", Value.Afs.roll ~ " " ~ sprintf("%03d", Value.Afs.hdg)));
				} else {
					me["FMA_Roll"].setText(sprintf("%s", Value.Afs.roll));
				}
				me["FMA_Roll"].show();
			} else {
				me["FMA_Roll"].hide();
			}
		}
		
		# FD
		if (Value.Afs.fd1) {
			me["FD_pitch"].show();
			me["FD_roll"].show();
		} else {
			me["FD_pitch"].hide();
			me["FD_roll"].hide();
		}
		
		# IRU
		if (pts.Instrumentation.Du.irsCapt.getBoolValue()) {
			Value.Iru.source[0] = 2; # AUX
		} else {
			Value.Iru.source[0] = 0;
		}
		
		if (Value.Iru.aligned[Value.Iru.source[0]]) {
			me["AI_error"].hide();
			me["AI_group"].show();
			me["AI_group2"].show();
			me["AI_group3"].show();
			me["AI_scale"].show();
			me["FD_group"].show();
			me["HDG_error"].hide();
			me["HDG_group"].show();
			me["VSI_error"].hide();
			me["VSI_group"].show();
		} else if (Value.Iru.aligning[Value.Iru.source[0]]) {
			me["AI_error"].hide();
			
			if (systems.IRS.Iru.attAvail[Value.Iru.source[0]].getBoolValue()) {
				me["AI_group"].show();
				me["AI_group2"].show();
				me["AI_group3"].show();
				if (systems.IRS.Iru.alignTimer[Value.Iru.source[0]].getValue() >= 31) {
					me["AI_scale"].show();
				} else {
					me["AI_scale"].hide();
				}
			} else {
				me["AI_group"].hide();
				me["AI_group2"].hide();
				me["AI_group3"].hide();
				me["AI_scale"].hide();
			}
			
			me["HDG_error"].hide();
			me["VSI_error"].hide();
			
			if (Value.Iru.mainAvail[Value.Iru.source[0]]) {
				me["FD_group"].show();
				me["HDG_group"].show();
				me["VSI_group"].show();
			} else {
				me["FD_group"].hide();
				me["HDG_group"].hide();
				me["VSI_group"].hide();
			}
		} else {
			me["AI_error"].show();
			me["AI_group"].hide();
			me["AI_group2"].hide();
			me["AI_group3"].hide();
			me["AI_scale"].hide();
			me["FD_group"].hide();
			me["HDG_error"].show();
			me["HDG_group"].hide();
			me["VSI_error"].show();
			me["VSI_group"].hide();
		}
		
		me.updateBase(0);
	},
};

var canvasPfd2 = {
	new: func(canvasGroup, file) {
		var m = {parents: [canvasPfd2, canvasBase]};
		m.init(canvasGroup, file);
		
		return m;
	},
	update: func() {
		# Provide the value to here and the base
		Value.Afs.ap1 = afs.Output.ap1.getBoolValue();
		Value.Afs.ap2 = afs.Output.ap2.getBoolValue();
		Value.Afs.ats = afs.Output.athr.getBoolValue();
		Value.Afs.fd2 = afs.Output.fd2.getBoolValue();
		Value.Afs.hdg = afs.Internal.hdg.getValue();
		Value.Afs.land = afs.Text.land.getValue();
		Value.Afs.pitch = afs.Fma.pitch.getValue();
		Value.Afs.pitchArm = afs.Fma.pitchArm.getValue();
		Value.Afs.roll = afs.Fma.roll.getValue();
		Value.Afs.rollArm = afs.Fma.rollArm.getValue();
		Value.Afs.thrust = afs.Text.spd.getValue();
		Value.Iru.aligned[0] = systems.IRS.Iru.aligned[0].getBoolValue();
		Value.Iru.aligned[1] = systems.IRS.Iru.aligned[1].getBoolValue();
		Value.Iru.aligned[2] = systems.IRS.Iru.aligned[2].getBoolValue();
		Value.Iru.aligning[0] = systems.IRS.Iru.aligning[0].getBoolValue();
		Value.Iru.aligning[1] = systems.IRS.Iru.aligning[1].getBoolValue();
		Value.Iru.aligning[2] = systems.IRS.Iru.aligning[2].getBoolValue();
		Value.Iru.mainAvail[0] = systems.IRS.Iru.mainAvail[0].getBoolValue();
		Value.Iru.mainAvail[1] = systems.IRS.Iru.mainAvail[1].getBoolValue();
		Value.Iru.mainAvail[2] = systems.IRS.Iru.mainAvail[2].getBoolValue();
		
		# FMA
		if (find("CLAMP", Value.Afs.pitch) != -1) {
			Value.Afs.pitch = Value.Afs.pitch ~ " ";
		}
		
		if (Value.Afs.fd2) {
			if (Value.Afs.land == "OFF") {
				me["FMA_Pitch"].setText(sprintf("%s", Value.Afs.pitch));
				me["FMA_Pitch"].show();
			} else {
				me["FMA_Pitch"].hide();
			}
			if (Value.Afs.roll == "HEADING" or Value.Afs.roll == "TRACK") {
				me["FMA_Roll"].setText(sprintf("%s", Value.Afs.roll ~ " " ~ sprintf("%03d", Value.Afs.hdg)));
			} else {
				me["FMA_Roll"].setText(sprintf("%s", Value.Afs.roll));
			}
			me["FMA_Roll"].show();
			me["FMA_Thrust"].setText(sprintf("%s", Value.Afs.thrust));
			me["FMA_Thrust"].show();
		} else {
			if (Value.Afs.thrust == "PITCH") {
				if (Value.Afs.ap1 or Value.Afs.ap2) {
					me["FMA_Thrust"].setText(sprintf("%s", Value.Afs.thrust));
					me["FMA_Thrust"].show();
				} else {
					me["FMA_Thrust"].hide();
				}
				if (Value.Afs.ats and Value.Afs.land == "OFF") {
					me["FMA_Pitch"].setText(sprintf("%s", Value.Afs.pitch));
					me["FMA_Pitch"].show();
				} else {
					me["FMA_Pitch"].hide();
				}
			} else {
				if ((Value.Afs.ap1 or Value.Afs.ap2) and Value.Afs.land == "OFF") {
					me["FMA_Pitch"].setText(sprintf("%s", Value.Afs.pitch));
					me["FMA_Pitch"].show();
				} else {
					me["FMA_Pitch"].hide();
				}
				if (Value.Afs.ats) {
					me["FMA_Thrust"].setText(sprintf("%s", Value.Afs.thrust));
					me["FMA_Thrust"].show();
				} else {
					me["FMA_Thrust"].hide();
				}
			}
			
			if (Value.Afs.ap1 or Value.Afs.ap2) {
				if (Value.Afs.roll == "HEADING" or Value.Afs.roll == "TRACK") {
					me["FMA_Roll"].setText(sprintf("%s", Value.Afs.roll ~ " " ~ sprintf("%03d", Value.Afs.hdg)));
				} else {
					me["FMA_Roll"].setText(sprintf("%s", Value.Afs.roll));
				}
				me["FMA_Roll"].show();
			} else {
				me["FMA_Roll"].hide();
			}
		}
		
		# FD
		if (Value.Afs.fd2) {
			me["FD_pitch"].show();
			me["FD_roll"].show();
		} else {
			me["FD_pitch"].hide();
			me["FD_roll"].hide();
		}
		
		# IRU
		if (pts.Instrumentation.Du.irsFo.getBoolValue()) {
			Value.Iru.source[1] = 2; # AUX
		} else {
			Value.Iru.source[1] = 1;
		}
		
		if (Value.Iru.aligned[Value.Iru.source[1]]) {
			me["AI_error"].hide();
			me["AI_group"].show();
			me["AI_group2"].show();
			me["AI_group3"].show();
			me["AI_scale"].show();
			me["FD_group"].show();
			me["HDG_error"].hide();
			me["HDG_group"].show();
			me["VSI_error"].hide();
			me["VSI_group"].show();
		} else if (Value.Iru.aligning[Value.Iru.source[1]]) {
			me["AI_error"].hide();
			
			if (systems.IRS.Iru.attAvail[Value.Iru.source[1]].getBoolValue()) {
				me["AI_group"].show();
				me["AI_group2"].show();
				me["AI_group3"].show();
				if (systems.IRS.Iru.alignTimer[Value.Iru.source[1]].getValue() >= 31) {
					me["AI_scale"].show();
				} else {
					me["AI_scale"].hide();
				}
			} else {
				me["AI_group"].hide();
				me["AI_group2"].hide();
				me["AI_group3"].hide();
				me["AI_scale"].hide();
			}
			
			me["HDG_error"].hide();
			me["VSI_error"].hide();
			
			if (Value.Iru.mainAvail[Value.Iru.source[1]]) {
				me["FD_group"].show();
				me["HDG_group"].show();
				me["VSI_group"].show();
			} else {
				me["FD_group"].hide();
				me["HDG_group"].hide();
				me["VSI_group"].hide();
			}
		} else {
			me["AI_error"].show();
			me["AI_group"].hide();
			me["AI_group2"].hide();
			me["AI_group3"].hide();
			me["AI_scale"].hide();
			me["FD_group"].hide();
			me["HDG_error"].show();
			me["HDG_group"].hide();
			me["VSI_error"].show();
			me["VSI_group"].hide();
		}
		
		me.updateBase(1);
	},
};

var canvasPfd1Error = {
	init: func(canvasGroup, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(canvasGroup, file, {"font-mapper": font_mapper});
		me.page = canvasGroup;
		
		return me;
	},
	new: func(canvasGroup, file) {
		var m = {parents: [canvasPfd1Error]};
		m.init(canvasGroup, file);
		
		return m;
	},
};

var canvasPfd2Error = {
	init: func(canvasGroup, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(canvasGroup, file, {"font-mapper": font_mapper});
		me.page = canvasGroup;
		
		return me;
	},
	new: func(canvasGroup, file) {
		var m = {parents: [canvasPfd2Error]};
		m.init(canvasGroup, file);
		
		return m;
	},
};

var init = func() {
	pfd1Display = canvas.new({
		"name": "PFD1",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	pfd2Display = canvas.new({
		"name": "PFD2",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	
	pfd1Display.addPlacement({"node": "pfd1.screen"});
	pfd2Display.addPlacement({"node": "pfd2.screen"});
	
	var pfd1Group = pfd1Display.createGroup();
	var pfd1ErrorGroup = pfd1Display.createGroup();
	var pfd2Group = pfd2Display.createGroup();
	var pfd2ErrorGroup = pfd2Display.createGroup();
	
	pfd1 = canvasPfd1.new(pfd1Group, "Aircraft/MD-11/Nasal/Displays/res/PFD.svg");
	pfd1Error = canvasPfd1Error.new(pfd1ErrorGroup, "Aircraft/MD-11/Nasal/Displays/res/Error.svg");
	pfd2 = canvasPfd2.new(pfd2Group, "Aircraft/MD-11/Nasal/Displays/res/PFD.svg");
	pfd2Error = canvasPfd2Error.new(pfd2ErrorGroup, "Aircraft/MD-11/Nasal/Displays/res/Error.svg");
	
	canvasBase.setup();
	update.start();
	
	if (pts.Systems.Acconfig.Options.Du.pfdFps.getValue() != 20) {
		rateApply();
	}
}

var rateApply = func() {
	update.restart(1 / pts.Systems.Acconfig.Options.Du.pfdFps.getValue());
}

var update = maketimer(0.05, func() { # 20FPS
	canvasBase.update();
});

var showPfd1 = func() {
	var dlg = canvas.Window.new([512, 512], "dialog", nil, 0).set("resize", 1);
	dlg.setCanvas(pfd1Display);
	dlg.set("title", "Captain's PFD");
}

var showPfd2 = func() {
	var dlg = canvas.Window.new([512, 512], "dialog", nil, 0).set("resize", 1);
	dlg.setCanvas(pfd2Display);
	dlg.set("title", "First Officer's PFD");
}

var roundAbout = func(x) { # Unused but left here for reference
	var y = x - int(x);
	return y < 0.5 ? int(x) : 1 + int(x);
}

var roundAboutAlt = func(x) { # For altitude tape numbers
	var y = x * 0.2 - int(x * 0.2);
	return y < 0.5 ? 5 * int(x * 0.2) : 5 + 5 * int(x * 0.2);
}

var genevaAltTenThousands = func(input) {
	var m = math.floor(input / 100);
	var s = math.max(0, (math.mod(input, 1) - 0.8) * 5);
	if (math.mod(input / 10, 1) < 0.9 or math.mod(input / 100, 1) < 0.9) s = 0;
	return m + s;
}

var genevaAltThousands = func(input) {
	var m = math.floor(input / 10);
	var s = math.max(0, (math.mod(input, 1) - 0.8) * 5);
	if (math.mod(input / 10, 1) < 0.9) s = 0;
	return m + s;
}

var genevaAltHundreds = func(input) {
	var m = math.floor(input);
	var s = math.max(0, (math.mod(input, 1) - 0.8) * 5);
	return m + s;
}
