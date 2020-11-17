[![GitHub stars](https://img.shields.io/github/stars/Shahabks/myprosody?style=flat-square)](https://github.com/Shahabks/myprosody/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Shahabks/myprosody?style=flat-square&color=blueviolet)](https://github.com/Shahabks/myprosody/network/members)

# myprosody
## **  The python script of myprosody revised and now is available here on "master branch" **
## *** Version-10 release: two new functions were added ***
### NEW VERSION: the prosodic features of speech (simultaneous speech) compared to the features of native speech ***spoken language proficiency level estimator

## NOTE:
    1- Both My-Voice-Analysis and Myprosody work on Python 3.7 
    2- If you install My-Voice-Analysis through PyPi, please use: 
          mysp=__import__("my-voice-analysis") instead of import myspsolution as mysp
    3- It it better to keep the folder names as single entities for instance "Name_Folder" or "NameFolder" without space in the dirctoy path

A Python library for measuring the acoustic features of speech (simultaneous speech, high entropy) compared to ones of native speech.

Prosody is the study of the tune and rhythm of speech and how these features contribute to meaning. Prosody is the study of those aspects of speech that typically apply to a level above that of the individual phoneme and very often to sequences of words (in prosodic phrases). Features above the level of the phoneme (or "segment") are referred to as suprasegmentals. 
A phonetic study of prosody is a study of the suprasegmental features of speech. At the phonetic level, prosody is characterised by: 

1.	vocal pitch (fundamental frequency)
2.	acoustic intensity
3.	rhythm (phoneme and syllable duration)

MyProsody is a Python library for measuring these acoustic features of speech (simultaneous speech, high entropy) compared to ones of native speech. The acoustic features of native speech patterns have been observed and established by employing Machine Learning algorithms. An acoustic model (algorithm) breaks recorded utterances (48 kHz & 32 bit sampling rate and bit depth respectively) and detects syllable boundaries, fundamental frequency contours, and formants. Its built-in functions recognize/measures:

                         o	Average_syll_pause_duration 
                         o	No._long_pause /o	Speaking-time 
                         o	No._of_words_in_minutes
                         o	Articulation_rate
                         o	No._words_in_minutes
                         o	formants_index
                         o	f0_index ((f0 is for fundamental frequency)
                         o	f0_quantile_25_index 
                         o	f0_quantile_50_index 
                         o	f0_quantile_75_index 
                         o	f0_std 
                         o	f0_max 
                         o	f0_min 
                         o	No._detected_vowel 
                         o	perc%._correct_vowel
                         o	(f2/f1)_mean (1st and 2nd formant frequencies)
                         o	(f2/f1)_std
                         o	no._of_words
                         o	no._of_pauses
                         o	intonation_index 
                         o	(voiced_syll_count)/(no_of_pause)
                         o	TOEFL_Scale_Score 
                         o	Score_Shannon_index
                         o	speaking_rate
                         o	gender recognition
                         o	speech mood (semantic analysis)
                         o	pronunciation posterior score
                         o	articulation-rate 
                         o	speech rate 
                         o	filler words
                         o	f0 statistics
                         -------------
                         NEW
                         --------------
                         o level (CEFR level)
                         o prosody-aspects (comparison, native level)

The library was developed based upon the idea introduced by Klaus Zechner et al “Automatic scoring of non-native spontaneous speech in tests of spoken English” Speech Communicaion vol 51-2009, Nivja DeJong and Ton Wempe [1], Paul Boersma and David Weenink [2], Carlo Gussenhoven [3], S.M Witt and S.J. Young [4] , and Yannick Jadoul [5].

Peaks in intensity (dB) that are preceded and followed by dips in intensity are considered as potential syllable cores. 
MyProsody is unique in its aim to provide a complete quantitative and analytical way to study acoustic features of a speech. Moreover, those features could be analysed further by employing Python's functionality to provide more fascinating insights into speech patterns. 

This library is for Linguists, scientists, developers, speech and language therapy clinics and researchers.  

Please note that MyProsody Analysis is currently in initial state though in active development. While the amount of functionality that is currently present is not huge, more will be added over the next few months.


## Installation

Myprosody can be installed like any other Python library, using (a recent version of) the Python package manager pip, on Linux, macOS, and Windows:

                                        pip install myprosody

or, to update your installed version to the latest release:

                                        pip install -u myprosody

you need also 

                                        import pickle
                                        
to run those functions of "Myprosody" which predict the spoken language proficiency level of your audio files. You need the pickle library to activate the trained acoustic and language models

## NOTE: 

After installing Myprosody, download the folder called:  

                                      myprosody

                                  
from

   https://github.com/Shahabks/myprosody

and save on your computer. The folder includes the audio files folder where you will save your audio files 
for analysis.

### Audio files must be in *.wav format, recorded at 48 kHz sample frame and 24-32 bits of resolution.

To check how the myprosody functions behave, please check 

                                    EXAMPLES.pdf
                                    testpro.py
                                    
on

  https://github.com/Shahabks/myprosody

## Development

Myprosody was developed by MYOLUTIONS Lab in Japan. It is part of New Generation of Voice Recognition and Acoustic & Language modelling Project in MYSOLUTIONS Lab. That is planned to enrich the functionality of Myprosody by adding more advanced functions. 

## Pronunciation
My-Voice-Analysis and MYprosody repos are two capsulated libraries from one of our main projects on speech scoring. The main project (its early version) employed ASR and used the Hidden Markov Model framework to train simple Gaussian acoustic models for each phoneme for each speaker in the given available audio datasets, then calculating all the symmetric K-L divergences for each pair of models for each speaker. What you see in these repos are just an approximate of those model without paying attention to level of accuracy of each phenome rather on fluency 
In the project's machine learning model we considered audio files of speakers who possessed an appropriate degree of pronunciation, either in general or for a specific utterance, word or phoneme, (in effect they had been rated with expert-human graders). Here below the figure illustrates some of the factors that the expert-human grader had considered in rating as an overall score

![image](https://user-images.githubusercontent.com/27753966/98312800-cf583a80-2015-11eb-9ecb-99658ecabdbb.png)

> [S. M. Witt, 2012 “Automatic error detection in pronunciation training: Where we are and where we need to go,” ](https://www.researchgate.net/publication/250306074_Automatic_Error_Detection_in_Pronunciation_Training_Where_we_are_and_where_we_need_to_go)


## References and Acknowledgements

1.	DeJong N.H, and Ton Wempe [2009]; “Praat script to detect syllable nuclei and measure speech rate automatically”; Behavior Research Methods, 41(2).385-390.

2.	 Paul Boersma and David Weenink;  http://www.fon.hum.uva.nl/praat/

3.	Gussenhoven C. [2002]; “ Intonation and Interpretation: Phonetics and Phonology”; Centre for Language Studies, Univerity of Nijmegen, The Netherlands.  

4.	Witt S.M and Young S.J [2000]; “Phone-level pronunciation scoring and assessment or interactive language learning”; Speech Communication, 30 (2000) 95-108.

5.	Jadoul, Y., Thompson, B., & de Boer, B. (2018). Introducing Parselmouth: A Python interface to Praat. Journal of Phonetics, 71, 1-15. https://doi.org/10.1016/j.wocn.2018.07.001 (https://parselmouth.readthedocs.io/en/latest/)

6. "Automatic scoring of non-native spontaneous speech in tests of spoken English", Speech Communication, Volume 51, Issue 10, October 2009, Pages 883-895

7. "A three-stage approach to the automated scoring of spontaneous spoken responses", Computer Speech & Language, Volume 25, Issue 2, April 2011, Pages 282-306

8. "Automated Scoring of Nonnative Speech Using the SpeechRaterSM v. 5.0 Engine", ETS research report, Volume 2018, Issue 1, December 2018, Pages: 1-28
