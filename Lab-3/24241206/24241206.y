%{

#include "symbol_table.h"
#include <cstring>
#include <map>
#include <vector>
#include <string>

#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

int lines = 1;

ofstream outlog;
ofstream errlog;

symbol_table st(10);
vector<symbol_info *> params;
int param_count = 0;

// Semantic-analysis state
string current_func_name;
vector<string> current_func_param_types;
vector<string> current_arg_types;
map<string, vector<string> > function_param_types;
map<string, string> function_return_types;
int error_count = 0;

void yyerror(char *s)
{
    outlog << "At line " << lines << " " << s << endl << endl;
}

// Find a symbol in the complete visible scope chain.
symbol_info* get_symbol_info(string name)
{
    symbol_info temp(name, "ID");
    return st.lookup(&temp);
}

// Check whether a symbol already exists in the current scope.
bool is_declared_current_scope(string name)
{
    symbol_info temp(name, "ID");
    return st.lookup_current_scope(&temp) != NULL;
}

bool is_function_symbol(symbol_info* sym)
{
    return sym != NULL && sym->get_symbol_type() == "Function Definition";
}

void semantic_error(string msg)
{
    outlog << "At line no: " << lines << " " << msg << endl << endl;
    errlog << "At line no: " << lines << " " << msg << endl << endl;
    error_count++;
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog<<"Symbol Table"<<endl<<endl;
		
		st.print_all_scopes(outlog);
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1->getname()+"\n"+$2->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"program");
	}
	;

unit : variable_decl
	 {
		outlog<<"At line no: "<<lines<<" unit : variable_decl "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     ;

func_definition : type_specifier ID LPAREN param_list RPAREN
        {
            current_func_name = $2->getname();
            $2->set_symbol_type("Function Definition");
            $2->set_return_type($1->getname());

            // Store the function parameter types before entering its body.
            function_param_types[current_func_name] = current_func_param_types;
            function_return_types[current_func_name] = $1->getname();

            // Add the same information to the function symbol used by the
            // existing symbol-table implementation.
            for (auto type : current_func_param_types) {
                $2->add_param_type(type);
            }

            if (is_declared_current_scope(current_func_name)) {
                semantic_error("Multiple declaration of function " + current_func_name);
            } else {
                st.insert($2);
            }
        }
        compound_statement
        {
            outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN param_list RPAREN compound_statement "<<endl<<endl;
            outlog<<$1->getname()<<" "<<$2->getname()<<"("+$4->getname()+")\n"+$7->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+" "+$2->getname()+"("+$4->getname()+")\n"+$7->getname(),"func_def");

            current_func_param_types.clear();
            current_func_name.clear();
        }
        | type_specifier ID LPAREN RPAREN
        {
            current_func_name = $2->getname();
            $2->set_symbol_type("Function Definition");
            $2->set_return_type($1->getname());

            current_func_param_types.clear();
            function_param_types[current_func_name] = current_func_param_types;
            function_return_types[current_func_name] = $1->getname();

            if (is_declared_current_scope(current_func_name)) {
                semantic_error("Multiple declaration of function " + current_func_name);
            } else {
                st.insert($2);
            }
        }
        compound_statement
        {
            outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
            outlog<<$1->getname()<<" "<<$2->getname()<<"()\n"+$6->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+" "+$2->getname()+"()\n"+$6->getname(),"func_def");

            current_func_param_types.clear();
            current_func_name.clear();
        }
        ;

param_list : param_list COMMA type_specifier ID
        {
            outlog<<"At line no: "<<lines<<" param_list : param_list COMMA type_specifier ID "<<endl<<endl;
            outlog<<$1->getname()<<","<<$3->getname()<<" "<<$4->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+","+$3->getname()+" "+$4->getname(),"param_list");

            $4->set_symbol_type("Variable");
            $4->set_return_type($3->getname());

            // Check duplicate parameter names.
            for (auto param : params) {
                if (param->getname() == $4->getname()) {
                    semantic_error("Multiple declaration of parameter " + $4->getname() + " in function " + current_func_name);
                    break;
                }
            }

            params.push_back($4);
            param_count++;
            current_func_param_types.push_back($3->getname());
        }
        | param_list COMMA type_specifier
        {
            outlog<<"At line no: "<<lines<<" param_list : param_list COMMA type_specifier "<<endl<<endl;
            outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+","+$3->getname(),"param_list");
            current_func_param_types.push_back($3->getname());
        }
        | type_specifier ID
        {
            outlog<<"At line no: "<<lines<<" param_list : type_specifier ID "<<endl<<endl;
            outlog<<$1->getname()<<" "<<$2->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+" "+$2->getname(),"param_list");

            $2->set_symbol_type("Variable");
            $2->set_return_type($1->getname());
            params.push_back($2);
            param_count++;
            current_func_param_types.push_back($1->getname());
        }
        | type_specifier
        {
            outlog<<"At line no: "<<lines<<" param_list : type_specifier "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"param_list");
            current_func_param_types.push_back($1->getname());
        }
        ;

compound_statement : LCURL
        {
            st.enter_scope();
            if (param_count > 0) {
                for (auto param : params) {
                    st.insert(param);
                }
                param_count = 0;
                params.clear();
            }
        }
        statements RCURL
        {
            outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
            outlog<<"{\n"+$3->getname()+"\n}"<<endl<<endl;

            $$ = new symbol_info("{\n"+$3->getname()+"\n}","comp_stmnt");

            st.print_all_scopes(outlog);
            st.exit_scope();
        }
        | LCURL RCURL
        {
            st.enter_scope();
            outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
            outlog<<"{\n}"<<endl<<endl;

            $$ = new symbol_info("{\n}","compound_statement");

            st.print_all_scopes(outlog);
            st.exit_scope();
        }
        ;

variable_decl : type_specifier declaration_list SEMICOLON
        {
            outlog<<"At line no: "<<lines<<" variable_decl : type_specifier declaration_list SEMICOLON "<<endl<<endl;
            outlog<<$1->getname()<<" "<<$2->getname()<<";"<<endl<<endl;

            $$ = new symbol_info($1->getname()+" "+$2->getname()+";","var_dec");

            if ($1->getname() == "void") {
                semantic_error("Variable type cannot be void");
            }

            stringstream ss_var($2->getname());
            string token_var;
            while (getline(ss_var, token_var, ',')) {
                size_t index_lthird = token_var.find("[");
                size_t index_rthird = token_var.find("]");

                string var_name = token_var;
                bool is_array = false;
                int array_size = 0;

                if (index_lthird != string::npos && index_rthird != string::npos) {
                    var_name = token_var.substr(0, index_lthird);
                    is_array = true;
                    string size_str = token_var.substr(index_lthird + 1, index_rthird - index_lthird - 1);
                    array_size = stoi(size_str);
                }

                if (is_declared_current_scope(var_name)) {
                    semantic_error("Multiple declaration of variable " + var_name);
                    continue;
                }

                symbol_info *var_sym;
                if (is_array) {
                    var_sym = new symbol_info(var_name, "ID");
                    var_sym->set_symbol_type("Array");
                    var_sym->set_return_type($1->getname());
                    var_sym->set_size(array_size);
                } else {
                    var_sym = new symbol_info(var_name, "ID");
                    var_sym->set_symbol_type("Variable");
                    var_sym->set_return_type($1->getname());
                }
                st.insert(var_sym);
            }
        }
        ;

type_specifier : INT
		{
			outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
			outlog<<"int"<<endl<<endl;
			
			$$ = new symbol_info("int","type");
	    }
 		| FLOAT
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
			outlog<<"float"<<endl<<endl;
			
			$$ = new symbol_info("float","type");
	    }
 		| VOID
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
			outlog<<"void"<<endl<<endl;
			
			$$ = new symbol_info("void","type");
	    }
		| CHAR
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : CHAR "<<endl<<endl;
			outlog<<"char"<<endl<<endl;
			
			$$ = new symbol_info("char","type");
	    }
 		;

declaration_list : declaration_list COMMA ID
		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<endl<<endl;

			$$ = new symbol_info($1->getname()+","+$3->getname(),"declaration_list");
 		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<"["<<$5->getname()<<"]"<<endl<<endl;

			$$ = new symbol_info($1->getname()+","+$3->getname()+"["+$5->getname()+"]","declaration_list");
 		  }
 		  | ID
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;

			$$ = new symbol_info($1->getname(),"declaration_list");
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
			outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
            
			$$ = new symbol_info($1->getname()+"["+$3->getname()+"]","declaration_list");
 		  }
 		  ;
 		  
statements : statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnts");
	   }
	   | statements statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
			outlog<<$1->getname()<<"\n"<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"stmnts");
	   }
	   ;
	   
statement : variable_decl
	  {
	    	outlog<<"At line no: "<<lines<<" statement : variable_decl "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | func_definition
	  {
	  		outlog<<"At line no: "<<lines<<" statement : func_definition "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"stmnt");
	  		
	  }
	  | expression_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | compound_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3->getname()<<$4->getname()<<$5->getname()<<")\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("for("+$3->getname()+$4->getname()+$5->getname()+")\n"+$7->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<"\nelse\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname()+"\nelse\n"+$7->getname(),"stmnt");
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"while("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("while("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
			outlog<<"printf("<<$3->getname()<<");"<<endl<<endl; 
			
			$$ = new symbol_info("printf("+$3->getname()+");","stmnt");
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
			outlog<<"return "<<$2->getname()<<";"<<endl<<endl;
			
			$$ = new symbol_info("return "+$2->getname()+";","stmnt");
	  }
	  ;
	  
expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;
				
				$$ = new symbol_info(";","expr_stmt");
	        }			
			| expression SEMICOLON 
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1->getname()<<";"<<endl<<endl;
				
				$$ = new symbol_info($1->getname()+";","expr_stmt");
	        }
			;
	  
variable : ID
        {
            outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            symbol_info *var_info = get_symbol_info($1->getname());
            $$ = new symbol_info($1->getname(),"varbl");

            if (var_info == NULL) {
                semantic_error("Undeclared variable " + $1->getname());
                $$->set_return_type("int");
            } else {
                if (var_info->get_symbol_type() == "Array") {
                    semantic_error("Variable is of array type: " + $1->getname());
                }
                $$->set_return_type(var_info->get_return_type());
            }
        }
        | ID LTHIRD expression RTHIRD
        {
            outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
            outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;

            symbol_info *var_info = get_symbol_info($1->getname());
            $$ = new symbol_info($1->getname()+"["+$3->getname()+"]","varbl");

            if (var_info == NULL) {
                semantic_error("Undeclared variable " + $1->getname());
                $$->set_return_type("int");
            } else {
                if (var_info->get_symbol_type() != "Array") {
                    semantic_error("Variable is not of array type: " + $1->getname());
                }
                $$->set_return_type(var_info->get_return_type());
            }

            if ($3->get_return_type() != "int") {
                semantic_error("Array index is not of integer type: " + $1->getname());
            }
        }
        ;

expression : logic_expression
        {
            outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"expr");
            $$->set_return_type($1->get_return_type());
        }
        | variable ASSIGNOP logic_expression
        {
            outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
            outlog<<$1->getname()<<"="<<$3->getname()<<endl<<endl;

            string lhs_type = $1->get_return_type();
            string rhs_type = $3->get_return_type();

            if (!lhs_type.empty() && !rhs_type.empty() && lhs_type != rhs_type) {
                if (lhs_type == "int" && rhs_type == "float") {
                    semantic_error("Warning: Assignment of float value into variable of int type");
                } else {
                    semantic_error("Type mismatch in assignment");
                }
            }

            $$ = new symbol_info($1->getname()+"="+$3->getname(),"expr");
            $$->set_return_type(lhs_type);
        }
        ;

logic_expression : rel_expression
        {
            outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"lgc_expr");
            $$->set_return_type($1->get_return_type());
        }
        | rel_expression LOGICOP rel_expression
        {
            outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
            outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"lgc_expr");
            $$->set_return_type("int");
        }
        ;

rel_expression : simple_expression
        {
            outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"rel_expr");
            $$->set_return_type($1->get_return_type());
        }
        | simple_expression RELOP simple_expression
        {
            outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
            outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"rel_expr");
            $$->set_return_type("int");
        }
        ;

simple_expression : term
        {
            outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"simp_expr");
            $$->set_return_type($1->get_return_type());
        }
        | simple_expression ADDOP term
        {
            outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
            outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"simp_expr");

            if ($1->get_return_type() == "float" || $3->get_return_type() == "float")
                $$->set_return_type("float");
            else
                $$->set_return_type("int");

            if ($1->get_return_type() == "void" || $3->get_return_type() == "void") {
                semantic_error("Operation on void type");
            }
        }
        ;

term : unary_expression
        {
            outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"term");
            $$->set_return_type($1->get_return_type());
        }
        | term MULOP unary_expression
        {
            outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
            outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"term");

            string left_type = $1->get_return_type();
            string right_type = $3->get_return_type();

            if ($2->getname() == "/" || $2->getname() == "%") {
                if ($3->getname() == "0") {
                    if ($2->getname() == "/")
                        semantic_error("Division by 0");
                    else
                        semantic_error("Modulus by 0");
                }
            }

            if ($2->getname() == "%") {
                if (left_type != "int" || right_type != "int") {
                    semantic_error("Modulus operator on non integer type");
                }
            }

            if (left_type == "void" || right_type == "void") {
                semantic_error("Operation on void type");
            }

            if (left_type == "float" || right_type == "float")
                $$->set_return_type("float");
            else
                $$->set_return_type("int");
        }
        ;

unary_expression : ADDOP unary_expression
        {
            outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
            outlog<<$1->getname()<<$2->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname()+$2->getname(),"un_expr");
            $$->set_return_type($2->get_return_type());

            if ($2->get_return_type() == "void") {
                semantic_error("Operation on void type");
            }
        }
        | NOT unary_expression
        {
            outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
            outlog<<"!"<<$2->getname()<<endl<<endl;

            $$ = new symbol_info("!"+$2->getname(),"un_expr");
            $$->set_return_type("int");
        }
        | factor_info
        {
            outlog<<"At line no: "<<lines<<" unary_expression : factor_info "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"un_expr");
            $$->set_return_type($1->get_return_type());
        }
        ;

factor_info : factor
        {
            outlog<<"At line no: "<<lines<<" factor_info : factor "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"fctr_info");
            $$->set_return_type($1->get_return_type());
        }
        ;

factor : variable
        {
            outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"fctr");
            $$->set_return_type($1->get_return_type());
        }
        | ID LPAREN argument_list RPAREN
        {
            outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
            outlog<<$1->getname()<<"("<<$3->getname()<<")"<<endl<<endl;

            $$ = new symbol_info($1->getname()+"("+$3->getname()+")","fctr");
            symbol_info *func_info = get_symbol_info($1->getname());

            if (func_info == NULL) {
                semantic_error("Undeclared function " + $1->getname());
                $$->set_return_type("int");
            } else if (!is_function_symbol(func_info)) {
                semantic_error($1->getname() + " is not a function");
                $$->set_return_type(func_info->get_return_type());
            } else {
                string func_name = $1->getname();
                string return_type = function_return_types[func_name];
                $$->set_return_type(return_type);

                vector<string> expected = function_param_types[func_name];

                if (current_arg_types.size() != expected.size()) {
                    semantic_error("Inconsistencies in number of arguments in function call: " + func_name);
                } else {
                    for (int i = 0; i < (int)expected.size(); i++) {
                        if (current_arg_types[i] != expected[i]) {
                            semantic_error("Argument " + to_string(i + 1) + " type mismatch in function call: " + func_name);
                        }
                    }
                }

                if (return_type == "void") {
                    // A void function is allowed as a standalone statement,
                    // but not as a value-producing factor/expression.
                    semantic_error("Void function used in expression: " + func_name);
                }
            }

            current_arg_types.clear();
        }
        | LPAREN expression RPAREN
        {
            outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
            outlog<<"("<<$2->getname()<<")"<<endl<<endl;

            $$ = new symbol_info("("+$2->getname()+")","fctr");
            $$->set_return_type($2->get_return_type());
        }
        | CONST_INT
        {
            outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"fctr");
            $$->set_return_type("int");
        }
        | CONST_FLOAT
        {
            outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"fctr");
            $$->set_return_type("float");
        }
        | variable INCOP
        {
            outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
            outlog<<$1->getname()<<"++"<<endl<<endl;

            $$ = new symbol_info($1->getname()+"++","fctr");
            $$->set_return_type($1->get_return_type());
        }
        | variable DECOP
        {
            outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
            outlog<<$1->getname()<<"--"<<endl<<endl;

            $$ = new symbol_info($1->getname()+"--","fctr");
            $$->set_return_type($1->get_return_type());
        }
        ;

argument_list : arguments
        {
            outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;
            $$ = new symbol_info($1->getname(),"arg_list");
        }
        |
        {
            outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
            outlog<<""<<endl<<endl;
            $$ = new symbol_info("","arg_list");
        }
        ;

arguments : arguments COMMA logic_expression
        {
            outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
            outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;

            current_arg_types.push_back($3->get_return_type());
            $$ = new symbol_info($1->getname()+","+$3->getname(),"arg");
        }
        | logic_expression
        {
            outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            current_arg_types.push_back($1->get_return_type());
            $$ = new symbol_info($1->getname(),"arg");
        }
        ;




%%

int main(int argc, char *argv[])
{
    if(argc != 2)
    {
        cout<<"Please input file name"<<endl;
        return 0;
    }

    yyin = fopen(argv[1], "r");
    outlog.open("24241206_log.txt", ios::trunc);
    errlog.open("24241206_error.txt", ios::trunc);

    if(yyin == NULL)
    {
        cout<<"Couldn't open file"<<endl;
        return 0;
    }

    // Enter the global scope before parsing.
    st.enter_scope();

    yyparse();

    outlog<<endl<<"Total lines: "<<lines<<endl;
    outlog<<"Total errors: "<<error_count<<endl;
    errlog<<"Total errors: "<<error_count<<endl;

    outlog.close();
    errlog.close();
    fclose(yyin);

    return 0;
}
