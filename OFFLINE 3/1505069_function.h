//
// Created by Latif Siddiq Suuny on 9-Jun-18.
//



#include <bits/stdc++.h>
using namespace std;

class Function
        {
        string return_type;
        int number_of_parameter;
        vector<string> parameter_list;
        vector<string> parameter_type;

        public:
            Function(){

            }
            void set_return_type(string type){
                this->return_type=type;
            }
            void set_number_of_parameter(){
                number_of_parameter=parameter_list.size();
            }
            void add_number_of_parameter(string newpara,string type){
                parameter_list.push_back(newpara);
                parameter_type.push_back(type);
                set_number_of_parameter();
            }
       

        };