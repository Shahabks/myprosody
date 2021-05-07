###########################################################################
#                                                                         #
#  Praat Script Spoken Communication Proficiency Test                     #
#  Copyright (C) 2017  Shahab Sabahi                                      #
#                                                                         #
#    This program is a Mysol software intellectual property:              # 
#    you can redistribute it and/or modify it under the terms             #
#    of the Mysol Permision.                                              #
#                                                                         #
#    This program is distributed in the hope that it will be useful,      #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of       #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                 #
#                                                                         #
#                                                                         #
###########################################################################
#
# modified 2017.05.26 by Shahab Sabahi, 
# Overview of changes: 
# + change threshold-calculator: rather than using median, use the almost maximum
#     minus 25dB. (25 dB is in line with the standard setting to detect silence
#     in the "To TextGrid (silences)" function.
#     Almost maximum (.99 quantile) is used rather than maximum to avoid using
#     irrelevant non-speech sound-bursts.
# + add silence-information to calculate articulation rate and ASD (average syllable
#     duration.
#     NB: speech rate = number of syllables / total time
#         articulation rate = number of syllables / phonation time
# + remove max number of syllable nuclei
# + refer to objects by unique identifier, not by name
# + keep track of all created intermediate objects, select these explicitly, 
#     then Remove
# + provide summary output in Info window
# + do not save TextGrid-file but leave it in Object-window for inspection
#     (if requested in startup-form)
# + allow Sound to have starting time different from zero
#      for Sound objects created with Extract (preserve times)
# + programming of checking loop for mindip adjusted
#      in the orig version, precedingtime was not modified if the peak was rejected !!
#      var precedingtime and precedingint renamed to currenttime and currentint
#
# + bug fixed concerning summing total pause, May 28th 2017
###########################################################################


# counts syllables of all sound utterances in a directory
# NB unstressed syllables are sometimes overlooked
# NB filter sounds that are quite noisy beforehand
# NB use Silence threshold (dB) = -20 (or -20?)
# NB use Minimum dip between peaks (dB) = between 2-4 (you can first try;
# For clean and filtered: 4)


form Counting Syllables in Sound Utterances
   real Silence_threshold_(dB) 
   real Minimum_dip_between_peaks_(dB) 
   real Minimum_pause_duration_(s) 
   boolean Keep_Soundfiles_and_Textgrids 
   sentence soundin  
   sentence directory 
   positive Minimum_pitch_(Hz) 
   positive Maximum_pitch_(Hz) 
   positive Time_step_(s) 
endform

# shorten variables
silencedb = 'silence_threshold'
mindip = 'minimum_dip_between_peaks'
showtext = 'keep_Soundfiles_and_Textgrids'
minpause = 'minimum_pause_duration'
 
# read files
 Read from file... 'soundin$'





# use object ID
   soundname$ = selected$("Sound")
   soundid = selected("Sound")
	      
   originaldur = Get total duration
   # allow non-zero starting time
   bt = Get starting time

   # Use intensity to get threshold
   To Intensity... 50 0 yes
   intid = selected("Intensity")
   start = Get time from frame number... 1
   nframes = Get number of frames
   end = Get time from frame number... 'nframes'

   # estimate noise floor
   minint = Get minimum... 0 0 Parabolic
   # estimate noise max
   maxint = Get maximum... 0 0 Parabolic
   #get .99 quantile to get maximum (without influence of non-speech sound bursts)
   max99int = Get quantile... 0 0 0.99

   # estimate Intensity threshold
   threshold = max99int + silencedb
   threshold2 = maxint - max99int
   threshold3 = silencedb - threshold2
   if threshold < minint
       threshold = minint
   endif

  # get pauses (silences) and speakingtime
   To TextGrid (silences)... threshold3 minpause 0.1 silent sounding
   textgridid = selected("TextGrid")
   silencetierid = Extract tier... 1
   silencetableid = Down to TableOfReal... sounding
   nsounding = Get number of rows
   npauses = 'nsounding'
   speakingtot = 0
   for ipause from 1 to npauses
      beginsound = Get value... 'ipause' 1
      endsound = Get value... 'ipause' 2
      speakingdur = 'endsound' - 'beginsound'
      speakingtot = 'speakingdur' + 'speakingtot'
   endfor

   select 'intid'
   Down to Matrix
   matid = selected("Matrix")
   # Convert intensity to sound
   To Sound (slice)... 1
   sndintid = selected("Sound")

   # use total duration, not end time, to find out duration of intdur
   # in order to allow nonzero starting times.
   intdur = Get total duration
   intmax = Get maximum... 0 0 Parabolic

   # estimate peak positions (all peaks)
   To PointProcess (extrema)... Left yes no Sinc70
   ppid = selected("PointProcess")

   numpeaks = Get number of points

   # fill array with time points
   for i from 1 to numpeaks
       t'i' = Get time from index... 'i'
   endfor 


   # fill array with intensity values
   select 'sndintid'
   peakcount = 0
   for i from 1 to numpeaks
       value = Get value at time... t'i' Cubic
       if value > threshold
             peakcount += 1
             int'peakcount' = value
             timepeaks'peakcount' = t'i'
       endif
   endfor


   # fill array with valid peaks: only intensity values if preceding 
   # dip in intensity is greater than mindip
   select 'intid'
   validpeakcount = 0
   currenttime = timepeaks1
   currentint = int1

   for p to peakcount-1
      following = p + 1
      followingtime = timepeaks'following'
      dip = Get minimum... 'currenttime' 'followingtime' None
      diffint = abs(currentint - dip)

      if diffint > mindip
         validpeakcount += 1
         validtime'validpeakcount' = timepeaks'p'
      endif
         currenttime = timepeaks'following'
         currentint = Get value at time... timepeaks'following' Cubic
   endfor


   # Look for only voiced parts
   select 'soundid' 
   To Pitch (ac)... 0.02 30 4 no 0.03 0.25 0.01 0.35 0.25 450
   # keep track of id of Pitch
   pitchid = selected("Pitch")

   voicedcount = 0
   for i from 1 to validpeakcount
      querytime = validtime'i'

      select 'textgridid'
      whichinterval = Get interval at time... 1 'querytime'
      whichlabel$ = Get label of interval... 1 'whichinterval'

      select 'pitchid'
      value = Get value at time... 'querytime' Hertz Linear

      if value <> undefined
         if whichlabel$ = "sounding"
             voicedcount = voicedcount + 1
             voicedpeak'voicedcount' = validtime'i'
         endif
      endif
   endfor

   
   # calculate time correction due to shift in time for Sound object versus
   # intensity object
   timecorrection = originaldur/intdur

   # Insert voiced peaks in TextGrid
   if showtext > 0
      select 'textgridid'
      Insert point tier... 1 syllables
      
      for i from 1 to voicedcount
          position = voicedpeak'i' * timecorrection
          Insert point... 1 position 'i'
      endfor
   endif

Save as text file: "'directory$'/'soundname$'.TextGrid"

# use object ID
	Read from file... 'soundin$'
	soundname$ = selected$("Sound")
	soundid = selected("Sound")
	fileName$ = "f0points'soundname$'.txt"

# Calculate F0 values
	To Pitch... time_step minimum_pitch maximum_pitch
	numberOfFrames = Get number of frames

# Loop through all frames in the Pitch object:
select Pitch 'soundname$'
unit$ = "Hertz"
min_Hz = Get minimum... 0 0 Hertz Parabolic
min$ = "'min_Hz'"
max_Hz = Get maximum... 0 0 Hertz Parabolic
max$ = "'max_Hz'"
mean_Hz = Get mean... 0 0 Hertz
mean$ = "'mean_Hz'"
stdev_Hz = Get standard deviation... 0 0 Hertz
stdev$ = "'stdev_Hz'"
median_Hz = Get quantile... 0 0 0.50 Hertz
median$ = "'median_Hz'"
quantile25_Hz = Get quantile... 0 0 0.25 Hertz
quantile25$ = "'quantile25_Hz'"
quantile75_Hz = Get quantile... 0 0 0.75 Hertz
quantile75$ = "'quantile75_Hz'"
# Collect and save the pitch values from the individual frames to the text file:
quantile250 = 'quantile25$'
quantile750 = 'quantile75$'
meanall = 'mean$'
q50='median$'
std='stdev$'
fmax='max$'
fmin='min$'

# clean up before next sound file is opened
    select 'intid'
    plus 'matid'
    plus 'sndintid'
    plus 'ppid'
    plus 'pitchid'
    plus 'silencetierid'
    plus 'silencetableid'

	Read from file... 'soundin$'
	soundname$ = selected$ ("Sound")
	To Formant (burg)... 0 5 5500 0.025 50
	Read from file... 'directory$'/'soundname$'.TextGrid
	int=Get number of intervals... 2

rstd=0
ins=0
qstd=0
lstd=0
nuofwrds=0
npause=0
xx=0
xxban$="0"	
vowel1=0
counter1=0
vsa=0
space=0
vectorf#= zero# (int)
vowelinx1=0
vowelinx2=0
formantmean=0
formantstd=0

if int<2
	warningfun$="A short talk or noisy background or unnatural-sounding speech detected. No result Try again"	
	else
		# We then calculate F1, F2 and F3

		fff= 0
		eee= 0
		inside= 0
		outside= 0
		for k from 2 to 'int'
			select TextGrid 'soundname$'
			label$ = Get label of interval... 2 'k'
			if label$ <> ""

			# calculates the onset and offset
				vowel_onset = Get starting point... 2 'k'
				vowel_offset = Get end point... 2 'k'

				select Formant 'soundname$'
				f_one = Get mean... 1 vowel_onset vowel_offset Hertz
				f_two = Get mean... 2 vowel_onset vowel_offset Hertz
				f_three = Get mean... 3 vowel_onset vowel_offset Hertz
				
				ff = 'f_two'/'f_one'
				lnf1 = 'f_one'
				lnf2f1 = ('f_two'/'f_one')
				uplim =(-0.012*'lnf1')+13.17
				lowlim =(-0.0148*'lnf1')+8.18
				space=((6.23*10^(-6)*(f_one)^2 + 0.09339*(f_one)+ 28.52)*(6.23*10^(-6)*(f_two)^2 + 0.09339*(f_two)+ 28.52))/1000
				if space>=15 and space<=28
					vsa=vsa+1
						elsif space>=3 and space<=12
							vsa=vsa+1
				else 
					vsa=vsa+0 
				endif
				
				f1uplim =(lnf2f1-13.17)/-0.012
				f1lowlim =(lnf2f1-8.18)/-0.0148
			
			if 1/ff<=0.176 and 1/ff>= 0.0744
				vowel1=vowel1+1
			else
				vowel1=vowel1+0
			endif
			if 1/ff<=0.227 and 1/ff>= 0.127
				vowel1=vowel1+1 
			else
				vowel1=vowel1+0
			endif
			if 1/ff<=0.245 and 1/ff>=0.145
				vowel1=vowel1+1
			else
				vowel1=vowel1+0
			endif
			if 1/ff<=0.361 and 1/ff>= 0.261
				vowel1=vowel1+1
			else 
				vowel1=vowel1+0
			endif
			if 1/ff<=0.605 and 1/ff>= 0.505
				vowel1=vowel1+1
			else 
				vowel1=vowel1+0
			endif
			if 1/ff<=0.760 and 1/ff>= 0.660
				vowel1=vowel1+1
			else 
				vowel1=vowel1+0
			endif
			if 1/ff<=0.733 and 1/ff>= 0.632
				vowel1=vowel1+1
			else 
				vowel1=vowel1+0
			endif
			if 1/ff<=0.489 and 1/ff>= 0.388
				vowel1=vowel1+1
			else 
				vowel1=vowel1+0
			endif
			if 1/ff<=0.414 and 1/ff>= 0.313
				vowel1=vowel1+1
			else 
				vowel1=vowel1+0
			endif
			if 1/ff<=0.312 and 1/ff>= 0.211
				vowel1=vowel1+1
			else 
				vowel1=vowel1+0
			endif
			if 1/ff<=0.569 and 1/ff>= 0.469
				vowel1=vowel1+1
			else 
				vowel1=vowel1+0
			endif
			
			counter1=counter1+1
	
		if lnf1>='f1lowlim' and lnf1<='f1uplim' 
			inside = 'inside'+1
			else
			   outside = 'outside'+1
		endif
		
		vectorf# [k] = ff
	
		fff = 'fff'+'f1uplim'
		eee = 'eee'+'f1lowlim'
			ffff = 'fff'/'int'
			eeee = 'eee'/'int'
			pron =('inside'*100)/('inside'+'outside')
			prom =('outside'*100)/('inside'+'outside')
			prob1 = invBinomialP ('pron'/100, 'inside', 'inside'+'outside')
			prob = 'prob1:2'
					
				endif
			endfor

			vowelinx1=vowel1
			vowelinx2=vsa/k
			formantmean=mean(vectorf#)
			formantstd=stdev(vectorf#)
			#shab = (ln(f_one)-5.65)/0.31
			#f00 = exp (shab)

			Remove
			if showtext < 1
			   select 'soundid'
			   plus 'textgridid'
			   Remove
			endif

		# summarize results in Info window
		   speakingrate = 'voicedcount'/'originaldur'
		   speakingraterp = ('voicedcount'/'originaldur')*100/3.93
		   articulationrate = 'voicedcount'/'speakingtot'
		   articulationraterp = ('voicedcount'/'speakingtot')*100/4.64
		   npause = 'npauses'-1
		   asd = 'speakingtot'/'voicedcount'
		   avenumberofwords = ('voicedcount'/1.74)/'speakingtot'
		   avenumberofwordsrp = (('voicedcount'/1.74)/'speakingtot')*100/2.66
		   nuofwrdsinchunk = (('voicedcount'/1.74)/'speakingtot')* 'speakingtot'/'npauses'
		   nuofwrdsinchunkrp = ((('voicedcount'/1.74)/'speakingtot')* 'speakingtot'/'npauses')*100/9
		   avepauseduratin = ('originaldur'-'speakingtot')/('npauses'-1)
		   avepauseduratinrp = (('originaldur'-'speakingtot')/('npauses'-1))*100/0.75
		   balance = ('voicedcount'/'originaldur')/('voicedcount'/'speakingtot')
		   balancerp = (('voicedcount'/'originaldur')/('voicedcount'/'speakingtot'))*100/0.85
		   nuofwrds= ('voicedcount'/1.74)
		   f1norm =(-0.0118*'pron'^2) + (0.5072*'pron')+394.34
		   inpro = ('nuofwrds'*60/'originaldur')
		   polish = 'originaldur'/2


		# Read the saved pitch points as a Matrix object:
		if meanall<150 
				q25='quantile250'/100
				q75='quantile750'/140
				mr= 'meanall'/119
			else
				q25='quantile250'/183
				q75='quantile750'/237
				mr= 'meanall'/210
		endif
	
	if nuofwrds<10 
				warningfun1$="Not enough words detected. Please speak longer."
			else
		#WARNING
			if originaldur>=60 and speakingtot>=polish and f1norm<=395 and eeee<=395 
				warning0$ = "NO WARNING"
				else
				warning0$ = "WARNING"
			 endif  
			if originaldur<60 
				warning1$ = "your speech lasts less than 60 seconds; it might affect the accuracy of your speech assessment" 
					else 
					warning1$ = " " 
			endif
			if speakingtot<polish 
				warning2$ = "Your speech is limited in content with long pause; it might affect the accuracy of your speech assessment" 
					else 
					warning2$ = " "	
			endif
			if f1norm>395 or eeee>395
				warning3$ = "There could be something wrong with your audio system OR your recorded voice is not clear OR your pronunciation level is limited"
					else
						warning3$ = " "
			endif

		# Convert the original minimum and maximum parameters in order to define the x scale of the
		if q25<=1 and q75<=1 and mr>=0.95 and mr<=1.05
				ins=10
			elsif q25<=1 and q75<=1 and mr>=0.9 and mr<=1.1
				ins=9
			elsif q25<=1 and q75<=1 and mr>=0.85 and mr<=1.15
				ins=8
			elsif mr>=0.9 and mr<=1.1
				ins=7
			elsif mr>=0.8 and mr<=1.2
				ins=6
			elsif mr<=0.8
				ins=4
			else
				ins=5
		endif  
		   
		#SCORING 
		if 	ins=4 
				 z=1.16 
					   elsif ins<=6 and ins>4 
							 z=2
								   elsif ins<9 and ins>6 
										z=3
							 elsif ins>=9 
								z=4
								else 
								 z=1                      
			endif

			if nuofwrdsinchunk>=6.24 and avepauseduratin<=1.0
				l=4
					elsif nuofwrdsinchunk>=6.24 and avepauseduratin>1.0
						l=3.6
							elsif nuofwrdsinchunk>=4.4 and nuofwrdsinchunk<=6.24 and avepauseduratin<=1.15
								l=3.3
									elsif nuofwrdsinchunk>=4.4 and nuofwrdsinchunk<=6.24 and avepauseduratin>1.15
										l=3
											elsif nuofwrdsinchunk<4.4 and avepauseduratin<=1.15
												l=2
													elsif nuofwrdsinchunk<=4.4 and avepauseduratin>1.15
														l=1.16
															else
																l=1
				endif
			if balance>=0.69 and avenumberofwords>=2.60 
				o=4
					 elsif balance>=0.60 and avenumberofwords>=2.43  
					   o=3.5 
					elsif balance>=0.5 and avenumberofwords>=2.25 
						o=3 
							elsif balance>=0.5 and avenumberofwords>=2.07 
								o=2 
								elsif balance>=0.5 and avenumberofwords>=1.95 
									o=1.16 
										else 
											o=1
				endif
			if speakingrate<=4.26 and speakingrate>=3.16 
				   q=4    
					 elsif speakingrate<=3.16 and speakingrate>=2.54 
					   q=3.5
				elsif speakingrate<=2.54 and speakingrate>=1.91 
					q=3
						 elsif speakingrate<=1.91 and speakingrate>=1.28  
							 q=2    
							   elsif speakingrate<=1.28 and speakingrate>=1.0 
								 q=1.16         
								   else 
									 q=1        
				endif
			if balance>=0.69 and articulationrate>=4.54 
				   w=4
					 elsif balance>=0.60 and articulationrate>=4.22 
					   w=3.5
				elsif balance>=0.50 and articulationrate>=3.91
					w=3
						 elsif balance>=0.5 and articulationrate>=3.59  
							 w=2
							   elsif balance>=0.5 and articulationrate>=3.10 
								  w=1.16
									 else 
										w=1 
			endif       
			if inpro>=119 and ('f1norm'*1.1)>=f1lowlim
				r = 4
					elsif inpro>=119 and ('f1norm'*1.1)<f1lowlim
						r = 3.8	
							elsif inpro<119 and inpro>=100 and ('f1norm'*1.1)>=f1lowlim
								r = 3.6
									elsif inpro<119 and inpro>=100 and ('f1norm'*1.1)<f1lowlim
										r = 3.4
											elsif inpro<100 and inpro>=80 and ('f1norm'*1.1)>=f1lowlim
												r= 3.2
										elsif inpro<100 and inpro>=80 and ('f1norm'*1.1)<f1lowlim
											r = 2.8
									elsif inpro<80 and inpro>=70 and ('f1norm'*1.1)>=f1lowlim
										r = 2.4
								elsif inpro<70 and inpro>=60 and ('f1norm'*1.1)>=f1lowlim
									r = 2
							elsif inpro<70 and inpro>=60 and ('f1norm'*1.1)<f1lowlim
								r = 1.1
						else 
							r = 0.3 				
										
			endif 

		if articulationrate>=4.80 and balance>=0.8
				qr = 4
					elsif articulationrate>=4.80 and balance<0.8
						qr = 3.8	
							elsif articulationrate<4.80 and articulationrate>=4.65 and balance>=0.8
								qr = 3.6
									elsif articulationrate<4.80 and articulationrate>=4.65 and balance<0.8
										qr = 3.4
											elsif articulationrate<4.65 and articulationrate>=4.55 and balance>=0.8
												qr= 3.2
										elsif articulationrate<4.65 and articulationrate>=4.55 and balance<0.8
											qr = 2.8
									elsif articulationrate<4.55 and articulationrate>=4.40 and balance>=0.8
										qr = 2.4
								elsif articulationrate<4.40 and articulationrate>=4.30 and balance>=0.8
									qr = 2
							elsif articulationrate<4.40 and articulationrate>=4.30 and balance<0.8
								qr = 1.5
						else 
							qr = 1 				
		endif	
			

		# summarize SCORE in Info window
		   totalscore =(l*2+z*4+o*3+qr*3+w*4+r*4)/20

		totalscale= 'totalscore'*25

		if totalscore>=3.6  
			  a=4
			   elsif totalscore>=0.6 and totalscore<2   
				 a=1
			   elsif totalscore>=2 and totalscore<3
					a=2
					  elsif totalscore>=3 and totalscore<3.6
						a=3
						   else
							 a=0.5   
		 endif

		if totalscale>=90  
			  s=4
			   elsif totalscale>=15 and totalscale<50   
				 s=1
			   elsif totalscale>=50 and totalscale<75
					s=2
					  elsif totalscale>=75 and totalscale<90
						s=3
						   else
							 s=0.5   
		endif

		#vvv=a+('totalscale'/100)
		vvv=totalscore+('totalscale'/100)

		if vvv>=4
			 u=4*(1-(randomInteger(1,16)/100))
			else 
			   u=vvv-(randomInteger(1,16)/100) 
		endif

		if totalscore>=4
			xx=30 
			elsif totalscore>=3.80 and totalscore<4 
			xx=29 
			elsif totalscore>=3.60 and totalscore<3.80 
			xx=28 
			elsif totalscore>=3.5 and totalscore<3.6 
			xx=27 
			elsif totalscore>=3.3 and totalscore<3.5 
			xx=26 
			elsif totalscore>=3.15 and totalscore<3.3 
			xx=25 
			elsif totalscore>=3.08 and totalscore<3.15 
			xx=24
			elsif totalscore>=3 and totalscore<3.08 
			xx=23
			elsif totalscore>=2.83 and totalscore<3 
			xx=22 
			elsif totalscore>=2.60 and totalscore<2.83 
			xx=21 
			elsif totalscore>=2.5 and totalscore<2.60 
			xx=20 
			elsif totalscore>=2.30 and totalscore<2.50 
			xx=19 
			elsif totalscore>=2.23 and totalscore<2.30 
			xx=18
			elsif totalscore>=2.15 and totalscore<2.23 
			xx=17
			elsif totalscore>=2 and totalscore<2.15 
			xx=16 
			elsif totalscore>=1.93 and totalscore<2 
			xx=15
			elsif totalscore>=1.83 and totalscore<1.93 
			xx=14
			elsif totalscore>=1.74 and totalscore<1.83 
			xx=13
			elsif totalscore>=1.66 and totalscore<1.74 
			xx=12
			elsif totalscore>=1.50 and totalscore<1.66 
			xx=11 
			elsif totalscore>=1.33 and totalscore<1.50 
			xx=10 
			else 
			xx=9 
		endif

		overscore = xx*4/30
		ov = overscore
		if xx>=25
			xxban$="C"
			elsif xx>=20 and xx<25
			xxban$="B2"
			elsif xx>=16 and xx<20
			xxban$="B1"
			elsif xx>=10 and xx<16
			xxban$="A2"
			else
			xxban$="A1"
		endif

		qaz = 0.18

		rr = (r*4+qr*2+z*1)/7
		lu = (l*1+w*2+inpro*4/125)/4
		td = (w*1+o*2+inpro*1/125)/3.25
		facts=(ln(7/4)*4/7+ln(7/2)*2/7+ln(7)*1/7+ln(4)*1/4+ln(2)*1/2+ln(4)*1/4+ln(3.25)*1/3.25+ln(3.25/2)*2/3.25+ln(3.25/0.25)*0.25/3.25+ln(14.25/7)*7/14.25+ln(14.25/4)*4/14.25+ln(14.25/3.35)*3.25/14.25)
		totsco = (r*ln(7/4)*4/7+qr*ln(7/2)*2/7+z*ln(7)*1/7+l*ln(4)*1/4+w*ln(2)*1/2+ln(4)*1/4*inpro*4/125+w*ln(3.25)*1/3.25+o*ln(3.25/2)*2/3.25+ln(3.25/0.25)*0.25/3.25*inpro*4/125)/facts

		if totalscore>=4
			  totsco=3.9
			   else
				 totsco=totalscore  
		 endif

		rrr = rr*qaz
		lulu = lu*qaz
		tdtd = td*qaz
		totscoo = totsco*qaz 
					   
		whx=rrr*cos(1.309)
		why=rrr*sin(1.309)
		who=4*qaz
				
		lstd=(10*l)/4
		ostd=(10*o)/4
		wstd=(10*w)/4				
		rstd=(10*r)/4
		zstd=(10*z)/4
		qstd=(10*qr)/4
		
		if q=4  
					xxx$="c"
				endif
					if q=3.5
						xxx$="b2"
					endif
					if q=3
						xxx$="b1"
					endif
						if q=2
							xxx$="a2"
						endif
					if q=1.16
						xxx$="a1"
					endif
				if q=1 
					xxx$="a"
				endif
				
				fillerratio='voicedcount'/'npause'
				
		# Long pause analysis variables
			silencedb = 'silence_threshold'
			mindip = 'minimum_dip_between_peaks'
			showtext = 'keep_Soundfiles_and_Textgrids'
			minpause = 0.8
 
			Read from file... 'soundin$'
			soundname$ = selected$("Sound")
			soundid = selected("Sound")
			originaldur = Get total duration
			bt = Get starting time

		To Intensity... 50 0 yes
		intid = selected("Intensity")
		start = Get time from frame number... 1
		nframes = Get number of frames
		end = Get time from frame number... 'nframes'

		minint = Get minimum... 0 0 Parabolic
		maxint = Get maximum... 0 0 Parabolic
		max99int = Get quantile... 0 0 0.99
		threshold = max99int + silencedb
		threshold2 = maxint - max99int
		threshold3 = silencedb - threshold2
		if threshold < minint
			threshold = minint
		endif

		To TextGrid (silences)... threshold3 minpause 0.1 silent sounding
		textgridid2 = selected("TextGrid")
		silencetierid = Extract tier... 1
		silencetableid = Down to TableOfReal... sounding
		nsounding = Get number of rows
		npausesz = 'nsounding'
		speakingtot = 0
		for ipause from 1 to npausesz
				beginsound = Get value... 'ipause' 1
				endsound = Get value... 'ipause' 2
				speakingdur = 'endsound' - 'beginsound'
				speakingtot = 'speakingdur' + 'speakingtot'
		endfor	  

		select 'intid'
		Down to Matrix
		matid = selected("Matrix")
		To Sound (slice)... 1
		sndintid = selected("Sound")
		intdur = Get total duration
		intmax = Get maximum... 0 0 Parabolic
		To PointProcess (extrema)... Left yes no Sinc70
		ppid = selected("PointProcess")
		numpeaks = Get number of points
		for i from 1 to numpeaks
				t'i' = Get time from index... 'i'
		endfor 
		select 'sndintid'
		peakcount = 0
		for i from 1 to numpeaks
				value = Get value at time... t'i' Cubic
				if value > threshold
						peakcount += 1
						int'peakcount' = value
						timepeaks'peakcount' = t'i'
				endif
		endfor

		select 'intid'
		validpeakcount = 0
		currenttime = timepeaks1
		currentint = int1

		for p to peakcount-1
				following = p + 1
				followingtime = timepeaks'following'
				dip = Get minimum... 'currenttime' 'followingtime' None
				diffint = abs(currentint - dip)
			if diffint > mindip
				validpeakcount += 1
				validtime'validpeakcount' = timepeaks'p'
			endif
				currenttime = timepeaks'following'
				currentint = Get value at time... timepeaks'following' Cubic
		endfor
		select 'soundid' 
		To Pitch (ac)... 0.02 30 4 no 0.03 0.25 0.01 0.35 0.25 450
		pitchid = selected("Pitch")
		voicedcount = 0
		for i from 1 to validpeakcount
					querytime = validtime'i'
					select 'textgridid2'
					whichinterval = Get interval at time... 1 'querytime'
					whichlabel$ = Get label of interval... 1 'whichinterval'
					select 'pitchid'
					value = Get value at time... 'querytime' Hertz Linear
				if value <> undefined
					if whichlabel$ = "sounding"
						voicedcount = voicedcount + 1
						voicedpeak'voicedcount' = validtime'i'
					endif
				endif
		endfor
		timecorrection = originaldur/intdur
		if showtext > 0
				select 'textgridid'
				Insert point tier... 1 syllables
					for i from 1 to voicedcount
							position = voicedpeak'i' * timecorrection
							Insert point... 1 position 'i'
					endfor
		endif
		Save as text file: "'directory$'/'soundname$'2.TextGrid"

		npausez= 'npausesz'		
				
		avelongpause='originaldur'/'npausez'	
				
		Erase all
		appendInfoLine:'avepauseduratin',tab$,'avelongpause',tab$,'speakingtot:2',tab$,'avenumberofwords',tab$,'articulationrate',tab$,'inpro',tab$,'f1norm',tab$,'mr',tab$,'q25',tab$,'q50',tab$,'q75', tab$, 'std',tab$,'fmax',tab$,'fmin',tab$,'vowelinx1',tab$,'vowelinx2',tab$,'formantmean',tab$,'formantstd',tab$,'nuofwrds:0',tab$,'npause',tab$,'ins',tab$,'fillerratio',tab$,'xx',tab$,xxx$,tab$,'totsco',tab$,xxban$,tab$,'speakingrate'
	endif	
	if nuofwrds<10
		appendInfoLine:'avepauseduratin',tab$,'avelongpause',tab$,'speakingtot:2',tab$,'avenumberofwords',tab$,'articulationrate',tab$,'inpro',tab$,'f1norm',tab$,'mr',tab$,'q25',tab$,'q50',tab$,'q75', tab$, 'std',tab$,'fmax',tab$,'fmin',tab$,'vowelinx1',tab$,'vowelinx2',tab$,'formantmean',tab$,'formantstd',tab$,'nuofwrds:0',tab$,'npause',tab$,'ins',tab$,'fillerratio',tab$,'xx',tab$,xxx$,tab$,'totsco',tab$,xxban$,tab$,'speakingrate'
	endif
endif
if int<2
	appendInfoLine: 0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0,tab$,0, tab$,0
endif
