%{
#include<iostream>
#include<cstdio>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "1505069_SymbolTable.h"
//#define YYSTYPE SymbolInfo*


using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *fp;
FILE *error=fopen("error.txt","w");
FILE *parsertext= fopen("parsertext.txt","w");
int line_count=1;
int error_count=0;


SymbolTable *table=new SymbolTable(100,parsertext);
vector<SymbolInfo*>para_list;
vector<SymbolInfo*>dec_list;


void yyerror(char *s)
{
	fprintf(stderr,"Line no %d : %s\n",line_count,s);

}



%}


%token IF ELSE FOR WHILE DO BREAK
%token INT FLOAT CHAR DOUBLE VOID
%token RETURN SWITCH CASE DEFAULT CONTINUE
%token CONST_INT CONST_FLOAT CONST_CHAR
%token ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT DECOP
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token STRING ID PRINTLN

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%union
{
        SymbolInfo* symbolinfo;
		vector<string>*s;
}
%type <s>start


%%

start : program {	}

	  ;

program : program unit {fprintf(parsertext,"Line at %d : program->program unit\n\n",line_count);
						fprintf(parsertext,"%s %s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str()); 
						$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name());
						}

	| unit {fprintf(parsertext,"Line at %d : program->unit\n\n",line_count);
	fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
	$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
	}
	;

unit : var_declaration {fprintf(parsertext,"Line at %d : unit->var_declaration\n\n",line_count);
						fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
						$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"\n");}
     | func_declaration {fprintf(parsertext,"Line at %d : unit->func_declaration\n\n",line_count);
	 					fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
						 $<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"\n");
						}
     | func_definition { fprintf(parsertext,"Line at %d : unit->func_definition\n\n",line_count);
	 					 fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
						 $<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"\n");
						 }
     ;

func_declaration : type_specifier ID  LPAREN  parameter_list RPAREN SEMICOLON {fprintf(parsertext,"Line at %d : func_declaration->type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
		fprintf(parsertext,"%s %s(%s);\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str(),$<symbolinfo>5->get_name().c_str());
		SymbolInfo *s=table->lookup($<symbolinfo>2->get_name());
				if(s==0){
					table->Insert($<symbolinfo>2->get_name(),"ID","Function");
					} 
		$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+"("+$<symbolinfo>5->get_name()+");");
		}
		|type_specifier ID LPAREN RPAREN SEMICOLON {fprintf(parsertext,"Line at %d : func_declaration->type_specifier ID LPAREN RPAREN SEMICOLON\n\n",line_count);
				fprintf(parsertext,"%s %s();\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str());
				SymbolInfo *s=table->lookup($<symbolinfo>2->get_name());
				if(s==0){
					table->Insert($<symbolinfo>2->get_name(),"ID","Function");
				}
				$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+"();");
		}
		;

func_definition : type_specifier ID  LPAREN  parameter_list RPAREN {
				SymbolInfo *s=table->lookup($<symbolinfo>2->get_name());
				if(s==0){
					table->InsertPrev($<symbolinfo>2->get_name(),"ID","Function");
					} 
				} compound_statement 
				{fprintf(parsertext,"Line at %d : func_definition->type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n",line_count);
				fprintf(parsertext,"%s %s(%s) %s \n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str(),$<symbolinfo>4->get_name().c_str(),$<symbolinfo>7->get_name().c_str());
				SymbolInfo *s=table->lookup($<symbolinfo>2->get_name());
				if(s==0){
					table->InsertPrev($<symbolinfo>2->get_name(),"ID","Function");
				}
				s=table->lookup($<symbolinfo>2->get_name());
				s->set_isFunction();
				for(int i=0;i<para_list.size();i++){
				s->get_isFunction()->add_number_of_parameter(para_list[i]->get_name(),para_list[i]->get_type());
				}
				para_list.clear();
				$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+"("+$<symbolinfo>4->get_name()+")"+$<symbolinfo>7->get_name());
				}
		| type_specifier ID LPAREN RPAREN { SymbolInfo *s=table->lookup($<symbolinfo>2->get_name());
											if(s==0){
												table->InsertPrev($<symbolinfo>2->get_name(),"ID","Function");
											}
											s=table->lookup($<symbolinfo>2->get_name());
											s->set_isFunction();
											$<symbolinfo>1->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+"()");
											} compound_statement {
											fprintf(parsertext,"Line at %d : func_definition->type_specifier ID LPAREN RPAREN compound_statement\n\n",line_count);
											fprintf(parsertext,"%s %s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>6->get_name().c_str());
											$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>6->get_name());
			
					}
 		;


parameter_list  : parameter_list COMMA type_specifier ID {fprintf(parsertext,"Line at %d : parameter_list->parameter_list COMMA type_specifier ID\n\n",line_count);
															fprintf(parsertext,"%s,%s %s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str(),$<symbolinfo>4->get_name().c_str());
															 para_list.push_back(new SymbolInfo($<symbolinfo>4->get_name(),"ID",$<symbolinfo>3->get_name()));
															$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name()+" "+$<symbolinfo>4->get_name());
															}
		| parameter_list COMMA type_specifier {fprintf(parsertext,"Line at %d : parameter_list->parameter_list COMMA type_specifier\n\n",line_count);
											fprintf(parsertext,"%s,%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
											$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name());

											}
 		| type_specifier ID {fprintf(parsertext,"Line at %d : parameter_list->type_specifier ID\n\n",line_count);
		 					fprintf(parsertext,"%s %s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str());
							para_list.push_back(new SymbolInfo($<symbolinfo>2->get_name(),"ID",$<symbolinfo>1->get_name()));
		 					$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name());
							}
		| type_specifier {fprintf(parsertext,"Line at %d : parameter_list->type_specifier\n\n",line_count);
			fprintf(parsertext,"%s \n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" ");
		}
 		;


compound_statement : LCURL statements RCURL {fprintf(parsertext,"Line at %d : compound_statement->LCURL statements RCURL\n\n",line_count);
											fprintf(parsertext,"{%s}\n\n",$<symbolinfo>2->get_name().c_str());
											$<symbolinfo>$->set_name("{\n"+$<symbolinfo>2->get_name()+"\n}");
											table->printall();
											table->Exit_Scope();
											}
 		    | LCURL RCURL {fprintf(parsertext,"Line at %d : compound_statement->LCURL RCURL\n\n",line_count);
			 				fprintf(parsertext,"{}\n\n");
			 				$<symbolinfo>$->set_name("{}");
							table->printall();
							table->Exit_Scope();
			 }
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON {fprintf(parsertext,"Line at %d : var_declaration->type_specifier declaration_list SEMICOLON\n\n",line_count);
															fprintf(parsertext,"%s %s;\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str());
															for(int i=0;i<dec_list.size();i++){
																if(table->lookupcurrent(dec_list[i]->get_name())){
																	 error_count++;
																	fprintf(error,"Error at Line No.%d:  Multiple Declaration of %s \n\n",line_count,dec_list[i]->get_name().c_str());
																	continue;
																}
																table->Insert(dec_list[i]->get_name(),dec_list[i]->get_type(),$<symbolinfo>1->get_name());
															}
															dec_list.clear();
															$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+";");
															}
 		 ;

type_specifier	: INT  {fprintf(parsertext,"Line at %d : type_specifier	: INT\n\n",line_count);fprintf(parsertext,"int \n\n");
				$<symbolinfo>$->set_name("int ");
				}
 		| FLOAT  {fprintf(parsertext,"Line at %d : type_specifier	: FLOAT\n\n",line_count);fprintf(parsertext,"float \n\n");
		 $<symbolinfo>$->set_name("float ");
		 }
 		| VOID  {fprintf(parsertext,"Line at %d : type_specifier	: VOID\n\n",line_count);fprintf(parsertext,"void \n\n");
		 $<symbolinfo>$->set_name("void ");
		 }
 		;

declaration_list : declaration_list COMMA ID {fprintf(parsertext,"Line at %d : declaration_list->declaration_list COMMA ID\n\n",line_count);
											fprintf(parsertext,"%s,%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
												dec_list.push_back(new SymbolInfo($<symbolinfo>3->get_name(),"ID"));
											$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name());
											}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {fprintf(parsertext,"Line at %d : declaration_list->declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
		   														fprintf(parsertext,"%s,%s[%s]\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str(),$<symbolinfo>5->get_name().c_str());
																dec_list.push_back(new SymbolInfo($<symbolinfo>3->get_name(),"ID"));
																$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name()+"["+$<symbolinfo>5->get_name()+"]");
																   }
 		  | ID {fprintf(parsertext,"Line at %d : declaration_list->ID\n\n",line_count);
		   fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
		   	dec_list.push_back(new SymbolInfo($<symbolinfo>1->get_name(),"ID"));
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
		
		   }
 		  | ID LTHIRD CONST_INT RTHIRD {fprintf(parsertext,"Line at %d : declaration_list->ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
		   fprintf(parsertext,"%s[%s]\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
		   	dec_list.push_back(new SymbolInfo($<symbolinfo>1->get_name(),"ID"));
		   	$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"["+$<symbolinfo>3->get_name()+"]");

		   }
 		  ;

statements : statement {fprintf(parsertext,"Line at %d : statements->statement\n\n",line_count);
						fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
						$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
						}
	   | statements statement {fprintf(parsertext,"Line at %d : statements->statements statement\n\n",line_count);
	   						fprintf(parsertext,"%s %s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str()); 
							   $<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"\n"+$<symbolinfo>2->get_name()); 
							   }
	   ;

statement : var_declaration { fprintf(parsertext,"Line at %d : statement -> var_declaration\n\n",line_count);
							fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
							$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 

							}
	  | expression_statement {fprintf(parsertext,"Line at %d : statement -> expression_statement\n\n",line_count);
	  						fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
							$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 

							  }
	  | compound_statement {fprintf(parsertext,"Line at %d : statement->compound_statement\n\n",line_count);
	  						fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
							 $<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
 
							  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {fprintf(parsertext,"Line at %d : statement ->FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_count);
	  																					fprintf(parsertext,"for(%s %s %s)\n%s \n\n",$<symbolinfo>3->get_name().c_str(),$<symbolinfo>4->get_name().c_str(),$<symbolinfo>5->get_name().c_str(),$<symbolinfo>7->get_name().c_str());
																						  $<symbolinfo>$->set_name("for("+$<symbolinfo>3->get_name()+$<symbolinfo>4->get_name()+$<symbolinfo>5->get_name()+")\n"+$<symbolinfo>5->get_name()); 

																						  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {fprintf(parsertext,"Line at %d : statement->IF LPAREN expression RPAREN statement\n\n",line_count);
	  																fprintf(parsertext,"if(%s)\n%s\n\n",$<symbolinfo>3->get_name().c_str(),$<symbolinfo>5->get_name().c_str());
																	$<symbolinfo>$->set_name("if("+$<symbolinfo>3->get_name()+")\n"+$<symbolinfo>5->get_name()); 

																	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {fprintf(parsertext,"Line at %d : statement->IF LPAREN expression RPAREN statement ELSE statement\n\n",line_count);
	  														fprintf(parsertext,"if(%s)\n%s\n else \n %s\n\n",$<symbolinfo>3->get_name().c_str(),$<symbolinfo>5->get_name().c_str(),$<symbolinfo>7->get_name().c_str());
															$<symbolinfo>$->set_name("if("+$<symbolinfo>3->get_name()+")\n"+$<symbolinfo>5->get_name()+" else \n"+$<symbolinfo>7->get_name()); 
															}

	  | WHILE LPAREN expression RPAREN statement {fprintf(parsertext,"Line at %d : statement->WHILE LPAREN expression RPAREN statement\n\n",line_count);
	  											fprintf(parsertext,"while(%s)\n%s\n\n",$<symbolinfo>3->get_name().c_str(),$<symbolinfo>5->get_name().c_str());
												  $<symbolinfo>$->set_name("while("+$<symbolinfo>3->get_name()+")\n"+$<symbolinfo>5->get_name()); 
												  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {fprintf(parsertext,"Line at %d : statement->PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count);
	  										fprintf(parsertext,"\n (%s);\n\n",$<symbolinfo>3->get_name().c_str());
											  $<symbolinfo>$->set_name("\n("+$<symbolinfo>3->get_name()+")"); 
											  }
	  | RETURN expression SEMICOLON {fprintf(parsertext,"Line at %d : statement->RETURN expression SEMICOLON\n\n",line_count);
	  								fprintf(parsertext,"return %s;\n\n",$<symbolinfo>2->get_name().c_str());
									$<symbolinfo>$->set_name("return "+$<symbolinfo>2->get_name()+";"); 
									}
	  ;

expression_statement 	: SEMICOLON	{fprintf(parsertext,"Line at %d : expression_statement->SEMICOLON\n\n",line_count);
									fprintf(parsertext,";\n\n"); 
									$<symbolinfo>$->set_name(";"); 
									}
			| expression SEMICOLON {fprintf(parsertext,"Line at %d : expression_statement->expression SEMICOLON\n\n",line_count);
									fprintf(parsertext,"%s;\n\n",$<symbolinfo>1->get_name().c_str());
										$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+";"); 
									}
			;

variable : ID 		{fprintf(parsertext,"Line at %d : variable->ID\n\n",line_count);
					fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
					if(table->lookup($<symbolinfo>1->get_name())==0){
						 error_count++;
						fprintf(error,"Error at Line No.%d:  Undeclared Variable: %s \n\n",line_count,$<symbolinfo>1->get_name().c_str());
					
					}
						$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
					}
	 | ID LTHIRD expression RTHIRD  {fprintf(parsertext,"Line at %d : variable->ID LTHIRD expression RTHIRD\n\n",line_count);
	 								fprintf(parsertext,"%s[%s]\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
									if(table->lookup($<symbolinfo>1->get_name())==0){
										 error_count++;
										fprintf(error,"Error at Line No.%d:  Undeclared Variable: %s \n\n",line_count,$<symbolinfo>1->get_name().c_str());
									}
									if($<symbolinfo>3->get_dectype()=="Float"){
										 error_count++;
										fprintf(error,"Error at Line No.%d:  Non-integer Array Index  \n\n",line_count);
									}
									$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"["+$<symbolinfo>3->get_name()+"]");  
									}
	 ;
expression : logic_expression	{fprintf(parsertext,"Line at %d : expression->logic_expression\n\n",line_count);
 								fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
								 	$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
								 }
	   | variable ASSIGNOP logic_expression {fprintf(parsertext,"Line at %d : expression->variable ASSIGNOP logic_expression\n\n",line_count);
	   										fprintf(parsertext,"%s=%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
											$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"="+$<symbolinfo>3->get_name());  

											}
	   ;
logic_expression : rel_expression 	{fprintf(parsertext,"Line at %d : logic_expression->rel_expression\n\n",line_count);
										fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
										$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
										}
		 | rel_expression LOGICOP rel_expression {fprintf(parsertext,"Line at %d : logic_expression->rel_expression LOGICOP rel_expression\n\n",line_count);
		 											fprintf(parsertext,"%s%s%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
		 											$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name()+$<symbolinfo>3->get_name());  

}
		 ;

rel_expression	: simple_expression {fprintf(parsertext,"Line at %d : rel_expression->simple_expression\n\n",line_count);
									fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
									$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
									}
		| simple_expression RELOP simple_expression	 {fprintf(parsertext,"Line at %d : rel_expression->simple_expression RELOP simple_expression\n\n",line_count);
													fprintf(parsertext,"%s%s%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
													$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name()+$<symbolinfo>3->get_name());  

													}
		;

simple_expression : term {fprintf(parsertext,"Line at %d : simple_expression->term\n\n",line_count);
							fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
							$<symbolinfo>$->set_name($<symbolinfo>1->get_name());  

							}
		  | simple_expression ADDOP{ $<symbolinfo>1->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name());} term { fprintf(parsertext,"Line at %d : simple_expression->simple_expression ADDOP term\n\n",line_count);
		  								fprintf(parsertext,"%s%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>4->get_name().c_str());
										 $<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>4->get_name());  
										  }
		  ;

term :	unary_expression  {fprintf(parsertext,"Line at %d : term->unary_expression\n\n",line_count);
							fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
							$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
							}
     |  term MULOP unary_expression {fprintf(parsertext,"Line at %d : term->term MULOP unary_expression\n\n",line_count);
	 								fprintf(parsertext,"%s%s%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
									 if($<symbolinfo>2->get_name()=="%"){
										 if($<symbolinfo>1->get_dectype()!="Int" ||$<symbolinfo>3->get_dectype()!="Int"  ){
											 error_count++;
											fprintf(error,"Error at Line No.%d:  Integer operand on modulus operator  \n\n",line_count);

										 }
									 }
									$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name()+$<symbolinfo>3->get_name()); 
									 }
     ;

unary_expression : ADDOP unary_expression  { fprintf(parsertext,"Line at %d : unary_expression->ADDOP unary_expression\n\n",line_count);
											fprintf(parsertext,"%s%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str());
											$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name()); 
										}
		 | NOT unary_expression {fprintf(parsertext,"Line at %d : unary_expression->NOT unary_expression\n\n",line_count);
		 fprintf(parsertext,"!%s\n\n",$<symbolinfo>2->get_name().c_str()); 
		 $<symbolinfo>$->set_name("!"+$<symbolinfo>2->get_name()); 
		 }
		 | factor {fprintf(parsertext,"Line at %d : unary_expression->factor\n\n",line_count);
		 		fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
				 $<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
		 }
		 ;

factor	: variable { fprintf(parsertext,"Line at %d : factor->variable\n\n",line_count);
					fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
					$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
					}
	| ID LPAREN argument_list RPAREN { fprintf(parsertext,"Line at %d : factor->ID LPAREN argument_list RPAREN\n\n",line_count);
									fprintf(parsertext,"%s(%s)\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
									$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"("+$<symbolinfo>3->get_name()+")"); 
									}
	| LPAREN expression RPAREN {fprintf(parsertext,"Line at %d : factor->LPAREN expression RPAREN\n\n",line_count);
								fprintf(parsertext,"(%s)\n\n",$<symbolinfo>2->get_name().c_str()); 
								$<symbolinfo>$->set_name("("+$<symbolinfo>2->get_name()+")"); 
								}
	| CONST_INT { fprintf(parsertext,"Line at %d : factor->CONST_INT\n\n",line_count);
				fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
				$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
				$<symbolinfo>$->set_dectype("Int"); 
				}
	| CONST_FLOAT {fprintf(parsertext,"Line at %d : factor->CONST_FLOAT\n\n",line_count);
					fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
					$<symbolinfo>$->set_name($<symbolinfo>1->get_name()); 
					$<symbolinfo>$->set_dectype("Float"); 
					}
	| variable INCOP {fprintf(parsertext,"Line at %d : factor->variable INCOP\n\n",line_count);
					fprintf(parsertext,"%s++\n\n",$<symbolinfo>1->get_name().c_str()); 
					 $<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"++"); 
					 }
	| variable DECOP {fprintf(parsertext,"Line at %d : factor->variable DECOP\n\n",line_count);
					fprintf(parsertext,"%s--\n\n",$<symbolinfo>1->get_name().c_str());
					 $<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"--"); 
					 }
	;

argument_list : arguments  { fprintf(parsertext,"Line at %d : argument_list->arguments\n\n",line_count);
							fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str());
							 $<symbolinfo>$->set_name($<symbolinfo>1->get_name());
							}
			  ;

arguments : arguments COMMA logic_expression { fprintf(parsertext,"Line at %d : arguments->arguments COMMA logic_expression \n\n",line_count);
											fprintf(parsertext,"%s,%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
											$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name());
											}
	      | logic_expression {fprintf(parsertext,"Line at %d : arguments->logic_expression\n\n",line_count);
		  fprintf(parsertext,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
		  $<symbolinfo>$->set_name($<symbolinfo>1->get_name());
		  }
	      ;
 %%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		return 0;
	}
	yyin=fp;
	table->Enter_Scope();
	yyparse();
	fprintf(parsertext," Symbol Table : \n\n");
	table->printall();
	fprintf(parsertext,"Total Lines : %d \n\n",line_count);
	fprintf(parsertext,"Total Errors : %d \n\n",error_count);
	fprintf(error,"Total Errors : %d \n\n",error_count);

	fclose(fp);
	fclose(parsertext);
	fclose(error);

	return 0;
}


