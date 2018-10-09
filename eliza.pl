#! usr/local/bin/perl
use strict;
use warnings;
use experimental 'smartmatch';

# I. Declaration of vars
my $INPUT = "";
my @INPUT_ARRAY = ();
my $word;
my $nMood;
my $notExists;
my $isValid=0;
my $arrlength;

#SYMPTOMS VARIABLES
my $stress; #anxiety, stress, work, pressure
my $depression; #sad #depress #negativeFeelings #to

# / !\Question: Comment doit-on ecrire les fichier pour les lire d'un autre pc?
my $FNeg = 'C:\Users\USP05\Desktop\ELIZA\AdjMood-.txt';
my $FPos = 'C:\Users\USP05\Desktop\ELIZA\AdjMood+.txt';
my $FVerbsFeeling = 'C:\Users\USP05\Desktop\ELIZA\VerbsFeeling.txt';
my $FVerbsAction = 'C:\Users\USP05\Desktop\ELIZA\VerbsAction.txt';
my $FNounsCommonDisorders = 'C:\Users\USP05\Desktop\ELIZA\NounsCommonDisorders.txt';

# Arrays to be filled from files:
my @AdjMoodNeg = (); #-ive words (feelings/mood)
my @AdjMoodPos = (); #+ive words (feelings/mood)
my @VerbsFeeling = (); #Feelings verbs. Used as (subject+verb+noun+ing | subject+verb+to+verb)
my @VerbsAction = (); #Action verbs.
my @NounsCommonDisorders = (); #Array with common mental disorders

#II. Create Databases
#**********************
# // Fill Arrays from files
&databaseInit();

# // ELIZA OUTPUT:
my @E_FEELINGQUESTIONS = ("How do you feel about today?\n", "What is your current state?\n");
my @E_DISORDERSQUESTIONS = ("Do you think you have a mental disorder?\n", "Do you feel sick?\n");
my @E_statement = ('If you were me, what would you say to someone else who <VerbsFeeling> this?\n', 'Why?\n', 'How?\n', 'Are you certain?\n', 'Really?\n', 'Does this worry you?', 'I understand\n', 'I see\n', 'Oh, I see\n', 'Could you elaborate more on this?\n', 'Really? How does that make you feel?\n');
my @E_youExists = ('My opinion does not matter. I think we should talk about you.\n', 'I am more conserned about what you
 verb\n', 'We could talk about me another time, but I would like us to 
 focus on you this time\n'); #[0]: thinking verbs, [1]: all verbs

# // PATIENT INPUT:
#Answers (REGEX) of Patient 
my @P_FEELING_REGEX = ('(i(\s|\w*\s)*am(\s|\w*\s)*feeling(\s.\w*)*)','(i(\s|\w)*feel(\s|\w)*)', '(i(\s|\w)*am(\s|\w)*)');
my @P_DISORDER_REGEX = ('(i(\s|\w*\s)*think(\s|\w*\s)*i\s*have(\s|\w*)*)');
#Affirmative and negative statements
my @P_statement = ('yes', 'no', 'sometimes', 'never', 'not really', 'always');
#if PATIENT asks about 'Eliza' using 'You'
my @P_youExists = ('\byou\w*'); 


#II. Functions:
# **************

#1- Function to fill arrays from files 
sub databaseInit()
{
	open (HANDLER1, "<", $FNeg) or die "AdjMood- File Writer Error: $!";
	open (HANDLER2, "<", $FPos) or die "AdjMood+ File Writer Error: $!";
	open (HANDLER3, "<", $FVerbsFeeling) or die "FVerbsFeeling File Writer Error: $!";
	open (HANDLER4, "<", $FNounsCommonDisorders) or die "FNounsCommonDisorders File Writer Error: $!";
	open (HANDLER5, "<", $FVerbsAction) or die "FVerbsAction File Writer Error: $!";

	while (<HANDLER1>)
	{
		chomp;
		push (@AdjMoodNeg, split '\n');
	}
	while (<HANDLER2>)
	{
		chomp;
		push (@AdjMoodPos, split '\n');
	}
	while (<HANDLER3>)
	{
		chomp;
		push(@VerbsFeeling, split '\n');
	}
	while (<HANDLER4>)
	{
		chomp;
		push(@NounsCommonDisorders, split '\n');
	}
	while (<HANDLER5>)
	{
		chomp;
		push(@VerbsAction, split '\n');
	}
	close(HANDLER1);
	close(HANDLER2);
	close(HANDLER3);
	close(HANDLER4);
	close(HANDLER5);
}

#2- INTRO of Eliza
sub intro()
{
	print "Hello! My name is Eliza and I am a psychotherapist, what is your name?\n";
	$INPUT = <STDIN>; #Patient's Name
	chomp $INPUT;

	#Name of the patient
	if ($INPUT =~m /my\s*name\s*is\s*([a-zA-Z]+)/i || $INPUT =~m /i\s*am\s*([a-zA-Z]+)/i || $INPUT =~m /([a-zA-Z]+)/i)
	{
		$INPUT = $1;
		print "Hello ".$INPUT.", how are you doing today?\n";
	}
	else
	{
		if ($INPUT =~m /my\s*name\s*is\s*(\W+)/i)
		{
			$INPUT = $1;
			print "Cute name! So, how are you doing today ".$INPUT."? \n";
		}
			#TODO: else: what if it was a question or sth else. Handle it later.
	}
}

#3- Eliza asks a random question from databases
sub askFeelings()
{
	$arrlength=@E_FEELINGQUESTIONS;
	my $rand = int (rand($arrlength));
	print $E_FEELINGQUESTIONS[$rand];
}
sub askDisorders()
{
	$arrlength=@E_DISORDERSQUESTIONS;
	my $rand = int (rand($arrlength));
	print $E_DISORDERSQUESTIONS[$rand];
}

#4- Matching Patient's INPUT
sub feelings
{
	#II.1 Check if in has words from NEGATIVE or POSITIVE Feelings/moods
	#Get Arguments (my ($args) --> should be between () )
	my ($in) = @_;
	@INPUT_ARRAY = split('\s', $in);
	$notExists = 0; #false
	for $word(@INPUT_ARRAY)
	{
		if(lc($word) eq "not")
		{
			$notExists = 1;
		}
		for $nMood(@AdjMoodNeg)
		{
		    if(lc($nMood) eq lc($word))
		    {
		        print "What do you think caused you to be $nMood?\n";
		        $isValid=1;
		    }
		}
		for my $pMood(@AdjMoodPos)
		{
		    if(lc($pMood) eq lc($word))
		    {
		    	if ($notExists==1) 
		    	{
		    		print "What do you think caused you to not to be $pMood?\n";
		    		$isValid=1;
		    	}
		        else
		        {
		        	print "I am happy that you are feeling $pMood, tell me more about it...\n";
		        	$isValid=1;
		        }
		    }
		}
	}
	return $isValid;
}
sub disorders() 
{
	#Get Arguments
	my ($in) = @_;
	@INPUT_ARRAY = split('\s', $in);

	my $disorder;
	my $rand = int (rand(2));
	for $word(@INPUT_ARRAY)
	{
		for $disorder(@NounsCommonDisorders)
		{
		    if(lc($disorder) eq lc($word)) #il faut ajouter davantage (le rand)
		    {
		        if($rand==0)
		        {
		        	print "What made you say you might have $disorder?\n";
		        }
		        if($rand==1)
		        {
		        	print "What made you think you have $disorder?\n";
		        }
		        $isValid=1;
		    }
		}
	}
	return $isValid;
}
# WRAPPER FUNCTION- Search Possible Patient Input in other database
sub inputOutput()
{
	#args: in
	my ($in) = @_;
	@INPUT_ARRAY = split('\s', $in);
	$isValid=0;
	my $rand;

	print "Eliza: "; # > Output
	#If input matches with a feeling verb 
	if(&isInDatabase(\@P_FEELING_REGEX, $in)==1 || $in ~~ @AdjMoodPos || $in ~~ @AdjMoodNeg)
	{
		$isValid = &feelings($in);
	}
	#If input matches with a disorder

	if(&isInDatabase(\@P_DISORDER_REGEX, $in)==1 || $in ~~ @NounsCommonDisorders)
	{
		$isValid = &disorders($in);
	}

	if(&isInDatabase(\@P_DISORDER_REGEX, $in)==1)
	{
		$arrlength=@E_youExists;
		$rand = int (rand($arrlength));
	}


	#If input is not valid (False=0)

	if ($isValid==0)
	{
		$rand = int (rand(2));
		if($rand == 0)
			{&askDisorders();}
		else
			{&askFeelings();}
	}
}

#5- Convert statement to question: from "I am" to "You are"
# sub iam_TO_youare()
# {	
# 	#Argument: INPUT
# 	my $in = @_;
# 	#Substitution
# 	my $subst =~ s/I am (\w*)/You are (\w*)/;
# }

#6- isInDatabase: check if answer matches a regex of the database
sub isInDatabase()
{
	#Pass argument: Database Name
	my @array = @{$_[0]};
	my $in = $_[1]; #+ error checking: @ is mandatory
	
	my $match;
	foreach $match(@array)
	{
		if($in =~ m /$match/i)
			{return 1;} #true = input exists in database
	}
	return 0;
}

&intro(); #START FROM HERE

while (1) #INFINITE LOOP
{
	print "Me: ";
	$INPUT = <STDIN>; #Answer
	chomp $INPUT;
	&inputOutput($INPUT);
	$isValid=0;
}

#Questions
#*********
# - No conjunctions (simple single sentences)
# - 
# /(a|b)*^(aa)$i/
# (^(the (rev|hon) )?(dr|mr|mrs\ms) (pat l\. )?robinson$)