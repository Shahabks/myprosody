from setuptools import setup

long_description="""*** Version-10 release: two new functions were added ***

The two new functions deploy different Machine Learning algorithms to estimate the speakers' spoken 
language proficiency levels (only the prosody aspect not semantically).  
 
Prosody is the study of the tune and rhythm of speech and how these features contribute to meaning. 
Prosody is the study of those aspects of speech that typically apply to a level above that of the individual 
phoneme and very often to sequences of words (in prosodic phrases). Features above the level of the phoneme 
(or "segment") are referred to as suprasegmentals. 
A phonetic study of prosody is a study of the suprasegmental features of speech. At the phonetic level, 
prosody is characterised by:

1.	vocal pitch (fundamental frequency)
2.	acoustic intensity
3.	rhythm (phoneme and syllable duration)

MyProsody is a Python library for measuring these acoustic features of speech (simultaneous speech, high entropy) 
compared to ones of native speech. The acoustic features of native speech patterns have been observed and 
established by employing Machine Learning algorithms. An acoustic model (algorithm) breaks recorded utterances 
(48 kHz & 32 bit sampling rate and bit depth respectively) and detects syllable boundaries, fundamental frequency
contours, and formants. Its built-in functions recognize/measures:

	Average_syll_pause_duration
	No._long_pause
	Speaking-time
	No._of_words_in_minutes
	Articulation_rate 
	No._words_in_minutes
	formants_index
	f0_index ((f0 is for fundamental frequency)
	f0_quantile_25_index
	f0_quantile_50_index
	f0_quantile_75_index
	f0_std
	f0_max
	f0_min
	No._detected_vowel
	perc%._correct_vowel
	(f2/f1)_mean (1st and 2nd formant frequencies)
	(f2/f1)_std
	no._of_words
	no._of_pauses
	intonation_index
	(voiced_syll_count)/(no_of_pause)
	TOEFL_Scale_Score
	Score_Shannon_index
	speaking_rate
	gender recognition 
	speech mood (semantic analysis)
	pronunciation posterior score 
	articulation-rate 
	speech rate
	filler words 
	f0 statistics
	-------------
	NEW
	--------------
	level (CEFR level)
	prosody-aspects (comparison, native level)
 
The library was developed based upon the idea introduced by Klaus Zechner et al 
*Automatic scoring of non-native spontaneous speech in tests of spoken English* Speech Communicaion vol 
51-2009, Nivja DeJong and Ton Wempe [1], Paul Boersma and David Weenink [2], Carlo Gussenhoven [3], 
S.M Witt and S.J. Young [4] and Yannick Jadoul [5].
 
Peaks in intensity (dB) that are preceded and followed by dips in intensity are considered as potential 
syllable cores. 

MyProsody is unique in its aim to provide a complete quantitative and analytical way to study acoustic 
features of a speech. Moreover, those features could be analysed further by employing Python's 
functionality to provide more fascinating insights into speech patterns. 

This library is for Linguists, scientists, developers, speech and language therapy clinics and researchers.   
Please note that MyProsody Analysis is currently in initial state though in active development. While the 
amount of functionality that is currently present is not huge, more will be added over the next few months.

											Installation
											=============
Myprosody can be installed like any other Python library, using (a recent version of) the Python package 
manager pip, on Linux, macOS, and Windows:

										pip install myprosody
				
or, to update your installed version to the latest release:
										
										pip install -u myprosody
				
NOTE:
============= 
After installing Myprosody, download the folder called:  
												
												myprosody 

from  https://github.com/Shahabks/myprosody

and save on your computer. The folder includes the audio files folder where you will save your audio files 
for analysis.

Audio files must be in *.wav format, recorded at 48 kHz sample frame and 24-32 bits of resolution.

To check how the myprosody functions behave, please check 
											
												EXAMPLES.pdf 
on  https://github.com/Shahabks/myprosody 

Myprosody was developed by MYOLUTIONS Lab in Japan. It is part of New Generation of Voice Recognition and Acoustic & Language modelling
Project in MYSOLUTIONS Lab. That is planned to enrich the functionality of Myprosody by adding more advanced 
functions."""
	
	
setup(name='myprosody',
      version='10',
      description='NEW VERSION: the prosodic features of speech (simultaneous speech) compared to the features of native speech +++ spoken language proficiency level estimator',
	  long_description=long_description,
	  url='https://github.com/Shahabks/myprosody',
      author='Shahab Sabahi',
      author_email='sabahi.s@mysol-gc.jp',
      license='MIT',
      classifiers=[
		'Intended Audience :: Developers',
		'Intended Audience :: Science/Research',
		'Programming Language :: Python',
		'Programming Language :: Python :: 3.7',
		],
	  keywords='praat speech signal processing phonetics',
	  install_requires=[
		'numpy>=1.15.2',
		'praat-parselmouth>=0.3.2',
		'pandas>=0.23.4',
		'scipy>=1.1.0',
		'pickleshare>=0.7.5',
		'scikit-learn>=0.20.2',
		],
	  packages=['myprosody'],
      zip_safe=False)
	  
