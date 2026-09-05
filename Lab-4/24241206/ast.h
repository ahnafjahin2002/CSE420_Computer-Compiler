#ifndef AST_H
#define AST_H

#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <map>


using namespace std;

class ASTNode {
    public:
        virtual ~ASTNode() {}
        virtual string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp, int& temp_count, int& label_count) const = 0;
};


class ExprNode : public ASTNode {
    protected:
        string node_type; //Type information(int, float, void, etc.)
    public:
        ExprNode(string type) : node_type(type) {}
        virtual string get_type() const { return node_type; }
};

// VarNode class modification 
class VarNode : public ExprNode {
    private:
        string name;
        ExprNode* index; 
    
    public:
        VarNode(string name, string type, ExprNode* idx = nullptr)
            : ExprNode(type), name(name), index(idx) {}
        
        ~VarNode() { if(index) delete index; }
        
        bool has_index() const { return index != nullptr; }
        
        string generate_index_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                                  int& temp_count, int& label_count) const {
            if (index) {
                
                string idx_temp = index->generate_code(outcode, symbol_to_temp, temp_count, label_count);

              
                string scale_temp = "t" + to_string(temp_count++);
                int scale_factor = 4; 

                if (node_type == "float" || node_type == "double") {
                    scale_factor = 8; // 8 bytes for float/double
                }

                outcode << scale_temp << " = " << idx_temp << " * " << scale_factor << endl;

                return scale_temp;
            }
            return "";
        }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            
            if (index) {
                string temp = "t" + to_string(temp_count++);
                string scaled_idx = generate_index_code(outcode, symbol_to_temp, temp_count, label_count);
                outcode << temp << " = " << name << "[" << scaled_idx << "]" << endl;
                return temp;
            } else {
 
                if (symbol_to_temp.find(name) != symbol_to_temp.end()) {
                    return symbol_to_temp[name]; // Return existing temp if variable already loaded
                }
                string temp = "t" + to_string(temp_count++);
                outcode << temp << " = " << name << endl;
                symbol_to_temp[name] = temp;
                return temp;
            }
        }
        
        string get_name() const { return name; }
};
    

// Constant node

class ConstNode : public ExprNode {
    private:
        string value;

    public:
        ConstNode(string val, string type) : ExprNode(type), value(val) {}
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            string const_temp = "t" + to_string(temp_count++);
            outcode << const_temp << " = " << value << endl;
            return const_temp;
        }
};

// Binary operation node

class BinaryOpNode : public ExprNode {
private:
    string op;
    ExprNode* left;
    ExprNode* right;

public:
    BinaryOpNode(string op, ExprNode* left, ExprNode* right, string result_type)
        : ExprNode(result_type), op(op), left(left), right(right) {}
    
    ~BinaryOpNode() {
        delete left;
        delete right;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        string left_temp = left->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        string right_temp = right->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        
        string result_temp = "t" + to_string(temp_count++);
        
        outcode << result_temp << " = " << left_temp << " " << op << " " << right_temp << endl;
        return result_temp;
    }
};

// Unary operation node

class UnaryOpNode : public ExprNode {
private:
    string op;
    ExprNode* expr;

public:
    UnaryOpNode(string op, ExprNode* expr, string result_type)
        : ExprNode(result_type), op(op), expr(expr) {}
    
    ~UnaryOpNode() { delete expr; }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        string expr_temp = expr->generate_code(outcode, symbol_to_temp, temp_count, label_count);

        string result_temp = "t" + to_string(temp_count++);
        
        outcode <<result_temp << " = " << op << expr_temp << endl;
        return result_temp;
    }
};

// Assignment node

class AssignNode : public ExprNode {
    private:
        VarNode* lhs;
        ExprNode* rhs;

    public:
        AssignNode(VarNode* lhs, ExprNode* rhs, string result_type)
            : ExprNode(result_type), lhs(lhs), rhs(rhs) {}
        
        ~AssignNode() {
            delete lhs;
            delete rhs;
        }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            // Generate code for right-hand side
            string rhs_temp = rhs->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            
            if (lhs->has_index()) { //if arrary
                string array_temp = symbol_to_temp[lhs->get_name()]; // Get the base array variable
                string idx_temp = lhs->generate_index_code(outcode, symbol_to_temp, temp_count, label_count);
                outcode << array_temp << "[" << idx_temp << "] = " << rhs_temp << endl;
            } else { //if variable
                string var_name = lhs->get_name();
                if (symbol_to_temp.find(var_name) == symbol_to_temp.end()) {
                    symbol_to_temp[var_name] = "t" + to_string(temp_count++);
                }
                
                string lhs_temp = symbol_to_temp[var_name];
                outcode << lhs_temp << " = " << rhs_temp << endl;
            }
            return rhs_temp;
        }
};

// Statement node types

class StmtNode : public ASTNode {
    public:
        virtual string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                                    int& temp_count, int& label_count) const = 0;
    };

    // Expression statement node

    class ExprStmtNode : public StmtNode {
    private:
        ExprNode* expr;

    public:
        ExprStmtNode(ExprNode* e) : expr(e) {}
        ~ExprStmtNode() { if(expr) delete expr; }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            if (expr) {
                // Just generate code for the expression
                expr->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            }
            return ""; // Statements don't need to return a temp
        }
};

// Block (compound statement) node

class BlockNode : public StmtNode {
    private:
        vector<StmtNode*> statements;

    public:
        ~BlockNode() {
            for (auto stmt : statements) {
                delete stmt;
            }
        }
        
        void add_statement(StmtNode* stmt) {
            if (stmt) statements.push_back(stmt);
        }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            for (auto stmt : statements) {
                stmt->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            }
            return "";
        }
};

// If statement node

class IfNode : public StmtNode {
    private:
        ExprNode* condition;
        StmtNode* then_block;
        StmtNode* else_block; // nullptr if no else part
    
    public:
        IfNode(ExprNode* cond, StmtNode* then_stmt, StmtNode* else_stmt = nullptr)
            : condition(cond), then_block(then_stmt), else_block(else_stmt) {}
        
        ~IfNode() {
            delete condition;
            delete then_block;
            if (else_block) delete else_block;
        }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            // Generate code for the condition
            string cond_temp = condition->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            
            // Match the exact format in code3.txt
            int then_label = label_count++;
            int else_label = label_count++;
            
            // Output the if condition and goto statements exactly as in code3.txt
            outcode << "if " << cond_temp << " goto L" << then_label << endl;
            outcode << "goto L" << else_label << endl;
            outcode << "L" << then_label << ":" << endl;
            
            // Generate code for the then block
            then_block->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            
            // Handle the else part if it exists
            if (else_block) {
                int end_label = label_count++;
                outcode << "goto L" << end_label << endl;
                outcode << "L" << else_label << ":" << endl;
                else_block->generate_code(outcode, symbol_to_temp, temp_count, label_count);
                outcode << "L" << end_label << ":" << endl;
            } else {
                // If there's no else block, just add the else label
                outcode << "L" << else_label << ":" << endl;
            }
            
            return "";
        }
};
// While statement node

class WhileNode : public StmtNode {
private:
    ExprNode* condition;
    StmtNode* body;

public:
    WhileNode(ExprNode* cond, StmtNode* body_stmt)
        : condition(cond), body(body_stmt) {}
    
    ~WhileNode() {
        delete condition;
        delete body;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        int start_label = label_count++;
        int body_label = label_count++;
        int end_label = label_count++; 
        
        outcode << "L" << start_label << ":" << endl;
        
        string cond_temp = condition->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        
        // If false, exit
        outcode << "if " << cond_temp << " goto L" << body_label << endl;
        outcode << "goto L" << end_label << endl;
        
        //body
        outcode << "L" << body_label << ":" << endl;
        body->generate_code(outcode, symbol_to_temp, temp_count, label_count); 

        
        // jump to condition 
        outcode << "goto L" << start_label << endl;
        outcode << "L" << end_label << ":" << endl;
        
        return "";
    }
};

class ForNode : public StmtNode {
    private:
        ExprNode* init;
        ExprNode* condition;
        ExprNode* update;
        StmtNode* body;
    
    public:
        ForNode(ExprNode* init_expr, ExprNode* cond_expr, ExprNode* update_expr, StmtNode* body_stmt)
            : init(init_expr), condition(cond_expr), update(update_expr), body(body_stmt) {}
        
        ~ForNode() {
            if (init) delete init;
            if (condition) delete condition;
            if (update) delete update;
            delete body;
        }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            // Generate initialization code
            if (init) {
                init->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            }
            
            int cond_label = label_count++;
            int body_label = label_count++;
            int end_label = label_count++;
            
            // Start of the loop: condition check
            outcode << "L" << cond_label << ":" << endl;

            if (condition) {
                string cond_temp = condition->generate_code(outcode, symbol_to_temp, temp_count, label_count);
                outcode << "if " << cond_temp << " goto L" << body_label << endl;
                outcode << "goto L" << end_label << endl;
            }

            outcode << "L" << body_label << ":" << endl;
            body->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            
    
            if (update) {
                update->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            }
            
            // Jump back to condition
            outcode << "goto L" << cond_label << endl;
            outcode << "L" << end_label << ":" << endl;
            
            
            return "";
        }
    };
// Return statement node

class ReturnNode : public StmtNode {
    private:
        ExprNode* expr;

    public:
        ReturnNode(ExprNode* e) : expr(e) {}
        ~ReturnNode() { if (expr) delete expr; }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            if (expr) {
                // Generate code for the return value
                string ret_temp = expr->generate_code(outcode, symbol_to_temp, temp_count, label_count);
                outcode << "return " << ret_temp << endl;
            } else {
                // Void return
                outcode << "return" << endl;
            }
            return "";
        }
};

// Declaration node

class DeclNode : public StmtNode {
    private:
        string type;
        vector<pair<string, int>> vars; // Variable name and array size (0 for regular vars)

    public:
        DeclNode(string t) : type(t) {}
        
        void add_var(string name, int array_size = 0) {
            vars.push_back(make_pair(name, array_size));
        }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            for (auto var : vars) {
                string var_name = var.first;
                int array_size = var.second;
                
                // Assign a temp name to this variable if it doesn't have one yet
                if (symbol_to_temp.find(var_name) == symbol_to_temp.end()) {
                    symbol_to_temp[var_name] = var.first; 
                }
                
                if (array_size > 0) {
                    outcode << "// Declaration: " << type << " " << var_name << "[" << array_size << "]" << endl;
                } else {
                    outcode << "// Declaration: " << type << " " << var_name << endl;
                }
            }
            return "";
        }
        
        string get_type() const { return type; }
        const vector<pair<string, int>>& get_vars() const { return vars; }
};

// Function declaration node

class FuncDeclNode : public ASTNode {
    private:
        string return_type;
        string name;
        vector<pair<string, string>> params; // Parameter type and name
        BlockNode* body;

    public:
        FuncDeclNode(string ret_type, string n) : return_type(ret_type), name(n), body(nullptr) {}
        ~FuncDeclNode() { if (body) delete body; }
        
        void add_param(string type, string name) {
            params.push_back(make_pair(type, name));
        }
        
        void set_body(BlockNode* b) {
            body = b;
        }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {
            // Resetting for each function
            symbol_to_temp.clear();
            
            outcode << "// Function: " << return_type << " " << name << "(";
            
            // Printing parameter list
            for (size_t i = 0; i < params.size(); ++i) {
                outcode << params[i].first << " " << params[i].second;
                if (i < params.size() - 1) {
                    outcode << ", ";
                }
            }
            outcode << ")" << endl;
            
            for (size_t i = 0; i < params.size(); ++i) {
                string param_name = params[i].second;
                // assigning temp variable to function params
                string temp_var = "t" + to_string(temp_count++);
                symbol_to_temp[param_name] = temp_var;
                outcode << temp_var << " = " << param_name << endl;
            }
            
            if (body) {
                body->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            }
            
            return "";
        }
};

// Helper class for function arguments

class ArgumentsNode : public ASTNode {
private:
    vector<ExprNode*> args;

public:
    ~ArgumentsNode() {
        // Don't delete args here - they'll be transferred to FuncCallNode
    }
    
    void add_argument(ExprNode* arg) {
        if (arg) args.push_back(arg);
    }
    
    ExprNode* get_argument(int index) const {
        if (index >= 0 && index < args.size()) {
            return args[index];
        }
        return nullptr;
    }
    
    size_t size() const {
        return args.size();
    }
    
    const vector<ExprNode*>& get_arguments() const {
        return args;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        return "";
    }
};

// Function call node

class FuncCallNode : public ExprNode {
private:
    string func_name;
    vector<ExprNode*> arguments;

public:
    FuncCallNode(string name, string result_type)
        : ExprNode(result_type), func_name(name) {}
    
    ~FuncCallNode() {
        for (auto arg : arguments) {
            delete arg;
        }
    }
    
    void add_argument(ExprNode* arg) {
        if (arg) arguments.push_back(arg);
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // Generate code for each argument
        vector<string> arg_temps;
        for (auto arg : arguments) {
            string arg_temp = arg->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            arg_temps.push_back(arg_temp);
        }
        
        // Push arguments in reverse order (convention for some architectures)
        
        for (int i = 0; i < arg_temps.size(); i++) {
            outcode << "param " << arg_temps[i] << endl;
        }
        
        
        // Create a temp for the function call result
        string result_temp = "t" + to_string(temp_count++);
        
        // Generate the function call
        outcode << result_temp << " = call " << func_name << ", " << arg_temps.size() << endl;
        
        return result_temp;
    }
};

// Program node (root of AST)

class ProgramNode : public ASTNode {
    private:
        vector<ASTNode*> units;

    public:
        ~ProgramNode() {
            for (auto unit : units) {
                delete unit;
            }
        }
        
        void add_unit(ASTNode* unit) {
            if (unit) units.push_back(unit);
        }
        
        string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                            int& temp_count, int& label_count) const override {

            for (auto unit : units) {
                unit->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            }
            
            return "";
        }
};

#endif // AST_H