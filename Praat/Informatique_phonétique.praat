##################################################################
##################################################################
#			Informatique et phonétique		
#			Devoir final 25/12/2020			
#			TEELOKEE MEVINE				
#								
#	Info script : Ce script permet d'extraire des données 
#   relatives aux fricatives des fichiers traités. 
#	
#						
##################################################################
##################################################################


# Formulaire afin de stocker les informations saisies en input par l'utilisateur dans des variables
form Mesure_Fricative
	#Indices des champs que l'on va traiter
	comment Indices des champs: phonéme et mot
	natural indice_Champ_Mot 1
	natural indice_Champ_Phoneme 2
	# Chemin d'acces du dossier contenant les fichiers son
	comment Dossier dans lequel se trouvent les fichiers son
	sentence cheminSon 
	# Chemin d'acces du dossier contenant les fichiers grille
	comment Dossier dans lequel se trouvent les fichiers grille 
	sentence cheminGrille 
	# Eventuel suffixe (Information importante : si l'utilisateur entre un suffixe celui-ci sera appliqué à tout les TxtGrid)
	comment Suffixe des fichiers grille ( si applicable )
	sentence suffixe 
	# Chemin de la sauvergarde du fichier .TXT ou l'on exportera nos resultats ainsi que le nom du fichier
	comment Dossier dans lequel les resultats seront exportes (le dossier doit exister)
	sentence dossierResultats 
	comment Nom du fichier de resultats
	sentence fichierResultat resultats
endform

# Stockage des extensions des fichiers son et txtgrid dans des variables 
extensionSon$ = ".wav"
extensionGrille$ = ".TextGrid"
# Utilisation d'une variable contenant une expression reguliere permettant de filtrer les sons selon le chemin d'acces et l'extension du fichier 
# dans notre cas tout les fichiers appartenant à un meme dossier dont l'extension se termine par .WAV 
regexSon$ = cheminSon$ + "\*" + extensionSon$
#Creation d'une liste en chaine de caractere contenant la denomination des sons en .WAV présent dans le dossier indiqué par l'utilisateur
listeFichSon = Create Strings as file list: "list_son",regexSon$
# Recuperation du nombre de chaines de caracteres différentes que notre liste contient
nFichiersSon = Get number of strings

##Initialisation des variables et compteurs utilisés dans notre script
# Compteur de controle utilisé pour verifier la  présense d'au moins deux fricatives afin de calculer l'ecart 
cptControleEcart = 0
# Compteur du nombre de phoneme entre les fricatives
compteurPhoneme = 0
# Compteur de controle verifiant l'existance d'une premiere occurence de fricative 
cptControlePremiereFricative = 0
# Compteur incrementiel de la durée des phonemes entre les fricatives
edureeFtempo = 0
# Echelle de conversion de secondes vers millisecondes
echelleSecondeMilliseconde = 1000

##### FIN DE LA DECLARATION DE VARIABLES ET DE LA CREATION d'OBJETS NECESSAIRES AU SCRIPT ########

# Creation d'un tableau et ecriture de l'en tete des colonnes dans notre tableau
tableau = Create Table with column names: "monTableau", 0, "Fichier.WAV SAMPA Milieu_fricative_dans_le_fichier(s) Durée(ms) Intensite(dB) Centre_de_gravité_spectrale(Hz) Nombre_de_phoneme_entre_fricative Durée_entre_fricative_(s) Mot_contenant_la_fricative Longueur_du_mot_en_phoneme Position_de_la_fricative_dans_le_mot"
## Creation d'une boucle iterative pour l'association des fichiers son avec leur fichiers txtgrid respectifs
# Recuperation de l'indice des chaines de carateres de notre liste et iteration de chaque fichier son présent dans notre dossier
for iFichier from 1 to nFichiersSon
	# On met à 0 notre variable compteur de controle quand l'on change de fichier à analysé
	cptControleEcart = 0
	# Attribution dans une variable du nom du fichier son correspondant à l'indice iFichier en cours
	selectObject: listeFichSon
	fichierSon$ = Get string: iFichier
	# Attribution dans une variable du fichier txtgrid a partir des informations obtenue du fichier son: modification des extensions et ajout eventuel de suffixe 
	if suffixe$ = ""
		fichierGrille$ = fichierSon$ - extensionSon$ +  extensionGrille$
	else
		fichierGrille$ = fichierSon$ - extensionSon$ + suffixe$ + extensionGrille$
	endif
	# Creation de nos objets Longsound et txtgrid que nous allons analyser dans cette itération
	son = Open long sound file: cheminSon$ + "\" + fichierSon$
	grille = Read from file: cheminGrille$  + "\" + fichierGrille$
	#Attribution du nombre d'intervalle de notre tier phoneme dans une variable
	selectObject: grille
	totalnInterval_ICP = Get number of intervals: indice_Champ_Phoneme
	# Boucle itérative for qui va analyser chaque intervalle contenu dans le tier Phoneme
	for nInterval from 1 to totalnInterval_ICP
		# Selection du textgrid et recupération du symbole SAMPA dans chaque intervalle
	  	selectObject: grille
		etiquette$ = Get label of interval: indice_Champ_Phoneme, nInterval
		# Notre variable de controle verifiant l'existance d'une occurence de fricative prend la valeur VRAI ici marqué comme la valeur numérique 1
		cptControlePremiereFricative = 1
		# Condition qui selectionne que les intervalles contenant des fricatives
	  	if etiquette$ = "f" or etiquette$ = "s" or etiquette$ = "S" or etiquette$ = "v" or etiquette$ = "z" or etiquette$ = "Z" 
	  		#Ajout d'une ligne a notre tableau
	  		selectObject: tableau
	  		Append row
	  		#Recuperation et stockage du nombre de ligne de notre tableau dans une variable
	  		iLigne = Get number of rows
	  		#Ajout dans le tableau du fichier .wav dans lequel se trouve la fricative
	  		Set string value:  iLigne, "Fichier.WAV", fichierSon$
  			# Ajout dans le tableau du symbole SAMPA associé à la fricative
  			Set string value:  iLigne, "SAMPA", etiquette$
  			# Attribution des données temporelle à des variables
			selectObject: grille
			tStart = Get start point: indice_Champ_Phoneme, nInterval
			tEnd = Get end point: indice_Champ_Phoneme, nInterval
			dureeF = tEnd - tStart
			tMilieuF = tStart + dureeF / 2
			# Ajout dans le tableau du temps en secondes correspondant au milieu de la fricative dans le fichier analysé
			# Pour un eventuel arrondisement des valeurs veuillez utiliser fixed$(y,x) 
			selectObject: tableau
			Set numeric value:  iLigne, "Milieu_fricative_dans_le_fichier(s)", tMilieuF
			# Ajout dans le tableau de la durée en millisecondes de la fricative
			Set numeric value:  iLigne, "Durée(ms)", dureeF * echelleSecondeMilliseconde
			# Extraction des segments à analysés
			selectObject: son
			extraitSon = Extract part: tStart, tEnd, "yes"
			# Recuperation de l'intensité sur le segment analysé
			selectObject: extraitSon
			valeurintensite = Get intensity (dB)
			# Ajout dans le tableau de l'intensité du segment analysé
			selectObject: tableau
			Set numeric value:  iLigne, "Intensite(dB)", valeurintensite
			# Recuperation des données pour l'analyse du centre de gravité spectrale
			selectObject: extraitSon
			spectre = To Spectrum: "yes"
			centreDeGravite = Get centre of gravity: 2
			# Ajout dans le tableau du centre de gravité spectrale du segment analysé
			selectObject: tableau
			Set numeric value:  iLigne, "Centre_de_gravité_spectrale(Hz)", centreDeGravite
			# Compteur de verification de deux phonemes pour commencer le calcul des ecarts
			cptControleEcart = cptControleEcart + 1
			# Si un ecart entre au moins deux fricatives est existante et que la fricative n'est 
			# pas a la dernier intervalle la condition est considérée comme etant vrai
			if cptControleEcart >= 2 and nInterval < totalnInterval_ICP	
				# Ajout dans le tableau du nombre de phoneme ainsi que la durée entre deux fricative 
				selectObject: tableau
				Set numeric value:  iLigne - 1, "Nombre_de_phoneme_entre_fricative", compteurPhoneme
				Set numeric value:  iLigne - 1, "Durée_entre_fricative_(s)", edureeFtempo
				# Reinitialisation des compteurs de phoneme et de durée
				compteurPhoneme = 0
				edureeFtempo = 0
			else 
				# Si la fricative se trouve à la derniere intervalle du champs phoneme nous entrons les donnees suivantes dans notre tableau
				if nInterval = totalnInterval_ICP
					# Mise à zero du compteur Phoneme car il n'y aura visiblement plus d'écart à calculer
					compteurPhoneme = 0
					# Ajout dans le teableau des valeurs nulles ou non definies
					selectObject: tableau
					Set numeric value:  iLigne, "Nombre_de_phoneme_entre_fricative", compteurPhoneme
					Set string value:  iLigne, "Durée_entre_fricative_(s)", "--undefined--"
				endif
			endif
			# Recuperation de l'indice de l'intervalle correspondant à la fricative sur le tier motnInterval
			selectObject: grille
			indiceIntervalMot = Get interval at time: indice_Champ_Mot, tMilieuF
			# Utilisation de l'indice de l'intervalle pour la recuperation du mot 
			etiquetteMot$ = Get label of interval: indice_Champ_Mot, indiceIntervalMot	
			# Ajout dans le tableau du mot contenant la fricative
			selectObject: tableau
	  		Set string value:  iLigne, "Mot_contenant_la_fricative", etiquetteMot$
	  		# Attribution de données temporelles lié au debut et a la fin du mot à des variables
	  		selectObject: grille
	  		debutMot = Get start point: indice_Champ_Mot, indiceIntervalMot
			finMot = Get end point: indice_Champ_Mot, indiceIntervalMot
			# Extraction du textgrid contenant uniquement le mot analysé
			extraitTxtGrid = Extract part: debutMot, finMot, "yes"
			# Recuperation du nombre d'intervalle du tier phoneme du mot analysé
			selectObject: extraitTxtGrid
			phonemeInterval = Get number of intervals: indice_Champ_Phoneme
			# Ajout dans le tableau du nombre de phoneme dans le mot contenant la fricative
			selectObject: tableau
			Set numeric value:  iLigne, "Longueur_du_mot_en_phoneme", phonemeInterval
			# Recuperation de la position de la fricative dans le mot grace à son indice dans le champ phoneme
			selectObject: extraitTxtGrid
			indiceIntervalPhon = Get interval at time: indice_Champ_Phoneme, tMilieuF
			selectObject: tableau
			Set numeric value:  iLigne, "Position_de_la_fricative_dans_le_mot", indiceIntervalPhon
			# Suppresion des fichiers temporaires
			selectObject: extraitSon
			plusObject: spectre
			plusObject: extraitTxtGrid
			Remove
		# Si l'intervalle testé n'est pas une fricative, le bloc d'instruction suivant s'execute
		# Condition qui s'execute tant que l'intervalle n'est pas un silence, ou qu'une premiere occurence de fricative ai deja été traitée et que
		# l'indice de l'intervalle analysé est inferieure au nombre total d'intervalle du champ phoneme 
		elsif etiquette$ <> "<p:>" and cptControlePremiereFricative = 1  and nInterval < totalnInterval_ICP	
				#Calcul de la durée du segment n'etant ni une silence ni une fricative
				selectObject: grille
				etStart = Get start point: indice_Champ_Phoneme, nInterval
				etEnd = Get end point: indice_Champ_Phoneme, nInterval
				edureeF = etEnd - etStart
				# Incrementation de la durée totales des phonemes entre les fricatives dans la variable edureeFtempo
				edureeFtempo = edureeFtempo + edureeF
				# Incrementation de notre compteur pour calculer le nombre de phoneme entre les fricatives
				compteurPhoneme = compteurPhoneme + 1
		else 
			# Condition qui s'execute seulement si l'itération de notre boucle for à atteint le dernier intervalle du champ phoneme
			if nInterval = totalnInterval_ICP
				# Mise à zero du compteur Phoneme car il n'y aura visiblement plus d'écart à calculer
				compteurPhoneme = 0
				# Ajout dans le teableau des valeurs nulles ou non definies
				selectObject: tableau
				Set numeric value:  iLigne , "Nombre_de_phoneme_entre_fricative", compteurPhoneme
				Set string value:  iLigne , "Durée_entre_fricative_(s)", "--undefined--"
			endif
		endif
	endfor
	# Suppresion des fichiers de l'interface utilisateur 
	selectObject: son
	plusObject: grille
	Remove
endfor

## Sauvegarde de notre tableau dans un fichier texte, nos resultats seront séparés par des tabulations et le script verifera si un fichier du meme nom existe deja 

# Condition de verification si un fichier du meme nom existe deja 
if fileReadable(dossierResultats$ + "\" + fichierResultat$ + ".txt") = 1
	beginPause: "Attention ! "
	       comment: "Un fichier du meme nom semble déja exister !"
	       boolean: "ecraser le fichier existant", 1
	clicked = endPause: "Valider mon choix et continuer ", 1
	# Si le booléen est coché le nouveau fichier ecrasera l'ancien fichier du meme nom
	if ecraser_le_fichier_existant
		selectObject: tableau
		Save as tab-separated file: dossierResultats$ + "\" + fichierResultat$ + ".txt"
	# En cas de refus d'enregistrement de l'utlisateur, le script arretera son execution en indiquant à l'utilisateur de relancer 
	# le script avec un autre nom à attribuer à son fichier de resultats
	else
		exitScript: "Veuillez relancer le script après avoir verifier la disponibilité de votre nom de fichier !"
	endif
# Si aucun fichier du meme nom existe le fichier s'enregistre normalement
else
	selectObject: tableau
	Save as tab-separated file: dossierResultats$ + "\" + fichierResultat$ + ".txt"
endif
# Suppresion des fichiers de l'interface utilisateur 
selectObject:listeFichSon
plusObject: tableau
Remove