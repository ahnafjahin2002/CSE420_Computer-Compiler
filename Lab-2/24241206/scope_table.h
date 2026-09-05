#ifndef SCOPE_TABLE_H
#define SCOPE_TABLE_H

#include "symbol_info.h"

class scope_table
{
private:
    int bucket_count;
    int unique_id;
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {
        unsigned long hash = 0;
        for (char c : name)
        {
            hash = (hash * 31 + c) % bucket_count;
        }
        return hash;
    }

public:
    scope_table() {}

    scope_table(int bucket_count, int unique_id, scope_table *parent_scope)
        : bucket_count(bucket_count), unique_id(unique_id), parent_scope(parent_scope)
    {
        table.resize(bucket_count);
    }

    scope_table *get_parent_scope()
    {
        return parent_scope;
    }

    int get_unique_id()
    {
        return unique_id;
    }

    symbol_info *lookup_in_scope(symbol_info* symbol)
    {
        string name = symbol->getname();
        int idx = hash_function(name);
        for (symbol_info *sym : table[idx])
        {
            if (sym->getname() == name)
            {
                return sym; 
            }
        }
        return nullptr;
    }

    bool insert_in_scope(symbol_info* symbol)
    {
        if (lookup_in_scope(symbol) != nullptr)
        {
            return false;
        }
        int idx = hash_function(symbol->getname());
        table[idx].push_back(symbol);
        return true;
    }

    bool delete_from_scope(symbol_info* symbol)
    {
        string name = symbol->getname();
        int idx = hash_function(name);
        for (auto it = table[idx].begin(); it != table[idx].end(); ++it)
        {
            if ((*it)->getname() == name)
            {
                table[idx].erase(it);
                return true;
            }
        }
        return false;
    }

    void print_scope_table(ofstream& outlog)
    {
        outlog << "ScopeTable # " + to_string(unique_id) << endl;

        for (int i = 0; i < bucket_count; ++i)
        {
            if (!table[i].empty()) 
            {
                outlog << i << " --> " << endl;
                for (symbol_info *sym : table[i])
                {
                    outlog << "< " << sym->getname() << " : " << sym->get_type() << " >" << endl;

                    if (sym->get_symbol_type() == "Function Definition")
                    {
                        vector<string> result = sym->get_params();
                        int sz = result.size();
                        sym->set_size(sz);

                        outlog << sym->get_symbol_type() << endl;
                        outlog << "Return Type: " << sym->get_return_type() << endl;
                        outlog << "Number of Parameters: " << sz << endl;

                        outlog << "Parameter Details: ";
                        for (size_t j = 0; j < sz; j++) 
                        {
                            outlog << result[j];
                            if (j != sz - 1) 
                            {
                                outlog << ", ";
                            }
                        }

                        outlog << endl;
                    }
                    else
                    {
                        outlog << sym->get_symbol_type() << endl;
                        outlog << "Type: " << sym->get_return_type() << endl;
                        if (sym->get_symbol_type() == "Array")
                        {
                            outlog << "Size: " << sym->get_size() << endl;
                        }
                    }
                }
                outlog << endl;
            }
        }
    }

    ~scope_table()
    {
        for (int i = 0; i < bucket_count; ++i)
        {
            for (symbol_info *sym : table[i])
            {
                delete sym;
            }
        }
    }
};

#endif