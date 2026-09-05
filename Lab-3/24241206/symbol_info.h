#ifndef SYMBOL_INFO_H
#define SYMBOL_INFO_H

#include <bits/stdc++.h>
using namespace std;

class symbol_info
{
private:
    string name;
    string type;


    string symbol_type = "NAN";
    string return_type;
    vector<string> params;
    int size = 0;

    string data_type;
    bool is_array = false;
    bool is_function = false;
    bool is_operation = false;
    bool is_undefined_function = false;

    symbol_info *next;

public:


    symbol_info()
    {
        name = "";
        type = "";
        symbol_type = "NAN";
        return_type = "";
        size = 0;

        is_array = false;
        is_function = false;
        is_operation = false;
        is_undefined_function = false;

        next = NULL;
    }

  
    symbol_info(string name, string type)
    {
        this->name = name;
        this->type = type;

        symbol_type = "NAN";
        return_type = "";
        size = 0;
        data_type = "";

        is_array = false;
        is_function = false;
        is_operation = false;
        is_undefined_function = false;

        next = NULL;
    }

  
    symbol_info(string name, string type, string data_type)
    {
        this->name = name;
        this->type = type;
        this->data_type = data_type;

        symbol_type = "NAN";
        return_type = "";
        size = 0;

        is_array = false;
        is_function = false;
        is_operation = false;
        is_undefined_function = false;

        next = NULL;
    }

    symbol_info(string name, string type, string data_type, int size)
    {
        this->name = name;
        this->type = type;
        this->data_type = data_type;
        this->size = size;

        symbol_type = "NAN";
        return_type = "";

        is_array = true;
        is_function = false;
        is_operation = false;
        is_undefined_function = false;

        next = NULL;
    }


    symbol_info(string name, string type, string return_type,
                vector<string> params)
    {
        this->name = name;
        this->type = type;
        this->return_type = return_type;
        this->params = params;

        symbol_type = "NAN";
        size = 0;
        data_type = "";

        is_array = false;
        is_function = true;
        is_operation = false;
        is_undefined_function = false;

        next = NULL;
    }

    string getname()
    {
        return name;
    }

    string get_type()
    {
        return type;
    }


    string gettype()
    {
        return type;
    }

    symbol_info *getnext()
    {
        return next;
    }

  
    string get_symbol_type()
    {
        return symbol_type;
    }

    string get_return_type()
    {
        return return_type;
    }

    int get_size()
    {
        return size;
    }

    vector<string> get_params()
    {
        return params;
    }

   
    string get_data_type()
    {
        return data_type;
    }

    bool get_is_array()
    {
        return is_array;
    }

    int get_array_size()
    {
        return size;
    }

    bool get_is_function()
    {
        return is_function;
    }

    bool get_is_operation()
    {
        return is_operation;
    }

    bool get_is_undefined_function()
    {
        return is_undefined_function;
    }

  
    void set_name(string name)
    {
        this->name = name;
    }

    void setname(string name)
    {
        this->name = name;
    }

    void set_type(string type)
    {
        this->type = type;
    }

    void settype(string type)
    {
        this->type = type;
    }

    void set_symbol_type(string symbol_type)
    {
        this->symbol_type = symbol_type;
    }

    void set_return_type(string return_type)
    {
        this->return_type = return_type;
    }

    void set_size(int size)
    {
        this->size = size;
        this->is_array = (size > 0);
    }


    void set_data_type(string data_type)
    {
        this->data_type = data_type;
    }

    void set_is_array(bool arr)
    {
        this->is_array = arr;
    }

    void set_array_size(int size)
    {
        this->size = size;
        this->is_array = true;
    }

    void set_is_operation()
    {
        this->is_operation = true;
    }

    void set_is_undefined_function()
    {
        this->is_undefined_function = true;
    }

    void set_as_function(string return_type, vector<string> params)
    {
        this->is_function = true;
        this->return_type = return_type;
        this->params = params;
        this->is_array = false;
    }

    void add_param_type(string param)
    {
        params.push_back(param);
    }

    void setnext(symbol_info *next)
    {
        this->next = next;
    }

    ~symbol_info()
    {
        if (next)
            delete next;
    }
};

#endif
