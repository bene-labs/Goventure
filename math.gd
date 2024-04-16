extends Node


func compute_expresion():
	Dialogic.VAR.MathRes = 0.0
	
	for i in Dialogic.VAR.MathExpr.split("+"):
		Dialogic.VAR.MathRes += float(i)
