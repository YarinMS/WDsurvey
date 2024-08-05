%% get a list of all fields with 2 consecutive nights of observations:

SaveToFields = '~/Documents/Master/NewResults/Fields'







%%
Fnames  =  [];
Fcoords = [];
Fpaths  =[];
Counts  =[];




%%

for Im = 5:10
    if Im<10
        Mount = ['0',num2str(Im)];
    else
        Mount = '10';

    end
    Imonth = ['08';'09';'10';'11';'12']
            for imonth = 1:length(Imonth)
                Month = Imonth(imonth,:);

                for Iday = 7:30

                    if Iday < 10
                        Night = ['0',num2str(Iday)];
                        if Iday<9
                            Night2 = ['0',num2str(Iday+1)];
                        else
                             Night2 = '10';
                        end

                    else
                        Night = num2str(Iday);
                        Night2 = num2str(Iday+1);

                    end

                    for Itel = 1:4
                     Tel   = Itel;
                     Year = '2023';

            

                    [Obj,FieldNames,FieldCoords,path,counts,counts2,Flag] = marvin_FieldsFinal(SaveToFields,'Mount',Mount,...
                    'Tel',Tel,...
                    'Year',Year,...
                     'Month',Month,'Night',Night,'Night2',Night2);

                    if Flag
                         Fnames  =  [Fnames ; {FieldNames}]
                         Fcoords = [Fcoords; FieldCoords]
                          Fpaths  =[Fpaths ;{path}]
                          Counts  =[Counts; {counts(:)'};{counts2(:)'}]

                    end


                end






            end



    end



end


%%
FieldNames = ['/Users/yarinms/marvin/LAST.01.02.03/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.02.03/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.02.01/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.02.01/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.02.02/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.02.02/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.02.03/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.02.03/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.02.01/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.02.01/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.02.02/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.02.02/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.02.03/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.02.03/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.02.04/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.02.04/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.03.02/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.03.03/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.04.01/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.04.01/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.04.02/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.04.02/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.04.03/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.04.03/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.04.04/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.04.04/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.04.01/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.04.02/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.04.03/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.04.04/2023/08/27/proc ',]

Fieldnames = [
    '291+34',
'356+34',
'292+39',
'358+34',
'292+39',
'358+34',
'292+39',
'358+34',
'field1064',
'field1130',
'field1064',
'field1130',
'field1064',
'field1130',
'field1064',
'field1130',
'291+51',
'291+51',
'247+41',
'265+61',
'247+41',
'265+61',
'247+41',
'265+61',
'247+41',
'265+61',
'337+36',
'337+36',
'337+36',
'337+36',]


FieldsRA = [289.95436246 , 
355.31804541 , 
293.10559240 , 
359.16549501 , 
293.09640417 , 
359.17954901 , 
290.67527909 , 
356.89314912 , 
25.47644867 , 
318.81312883 , 
25.50961335 , 
318.83313911 , 
23.46457588 , 
316.78693528 , 
23.41873353 , 
316.74643032 , 
292.66923332 , 
289.80139246 , 
247.58577586 , 
265.22785524 , 
247.57362612 , 
265.20958698 , 
247.59135872 , 
265.26764713 , 
247.52833664 , 
265.19026170 , 
337.58792778 , 
337.56864522 , 
337.62255903 , 
337.57896991 , 
]

FieldDec = [
    33.07577094 , 
33.08081279 , 
40.33853253 , 
35.82886087 , 
37.36027052 , 
32.86415035 , 
37.54821955 , 
33.04453224 , 
24.17978993 , 
24.18432234 , 
21.23996995 , 
21.23290171 , 
21.41735536 , 
21.41410847 , 
24.15836193 , 
24.14428945 , 
50.21225469 , 
49.96580861 , 
41.44798092 , 
61.17029258 , 
41.56607004 , 
61.29799154 , 
41.61078068 , 
61.33381147 , 
41.62888117 , 
61.34081764 , 
36.58826720 , 
36.73685282 , 
36.79249283 , 
36.77247627 ,]











%% more 60 fields


%
FieldNames = [

'/Users/yarinms/marvin/LAST.01.06.02/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.06.04/2023/08/15/proc ', 
'/Users/yarinms/marvin/LAST.01.06.04/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.06.04/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.06.01/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.06.01/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.06.04/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.06.04/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.06.01/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.06.01/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.06.03/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.06.03/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.06.04/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.06.04/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.06.02/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.06.02/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.06.03/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.06.03/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.06.04/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.06.04/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.08.01/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.08.01/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.08.02/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.08.02/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.08.03/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.08.03/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.08.04/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.08.04/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.08.01/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.08.01/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.08.02/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.08.02/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.08.03/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.08.03/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.08.04/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.08.04/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.10.01/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.10.01/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.10.02/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.10.02/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.10.03/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.10.03/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.10.04/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.10.04/2023/08/21/proc ', 
'/Users/yarinms/marvin/LAST.01.10.01/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.10.01/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.10.02/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.10.02/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.10.03/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.10.03/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.10.04/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.10.04/2023/08/27/proc ', 
'/Users/yarinms/marvin/LAST.01.10.01/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.10.01/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.10.02/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.10.02/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.10.03/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.10.03/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.10.04/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.10.04/2023/09/15/proc ', 
'/Users/yarinms/marvin/LAST.01.10.03/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.10.03/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.10.04/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.10.04/2023/11/08/proc ', 
'/Users/yarinms/marvin/LAST.01.10.01/2023/12/14/proc ', 
'/Users/yarinms/marvin/LAST.01.10.02/2023/12/14/proc ', 
'/Users/yarinms/marvin/LAST.01.10.03/2023/12/14/proc ', 
'/Users/yarinms/marvin/LAST.01.10.04/2023/12/14/proc ',     
]


Fieldnames = [
    '277+36',
'277+36',
'290+39',
'354+39',
'312+26',
'355+45',
'312+26',
'355+45',
'field1221',
'field1280',
'field1221',
'field1280',
'field1221',
'field1280',
'field1229',
'field1286',
'field1229',
'field1286',
'field1229',
'field1286',
'291+45',
'356+45',
'291+45',
'356+45',
'291+45',
'356+45',
'291+45',
'356+45',
'field1073',
'field1136',
'field1073',
'field1136',
'field1073',
'field1136',
'field1073',
'field1136',
'291+23',
'356+23',
'291+23',
'356+23',
'291+23',
'356+23',
'291+23',
'356+23',
'280+40',
'351+32',
'280+40',
'351+32',
'280+40',
'351+32',
'280+40',
'351+32',
'field1144',
'field1207',
'field1144',
'field1207',
'field1144',
'field1207',
'field1144',
'field1207',
'field1153',
'field1213',
'field1153',
'field1213',
'074+55',
'074+55',
'074+55',
'074+55',
]

FieldsRA = [
278.50976329 , 
276.19654538 , 
289.59654920 , 
352.75452464 , 
313.29859471 , 
356.87205830 , 
311.05466916 , 
354.02083032 , 
23.46145962 , 
318.47463714 , 
20.99634246 , 
315.97798249 , 
21.08707472 , 
316.06273590 , 
63.46156844 , 
348.47544045 , 
61.12964661 , 
346.13428844 , 
61.18234804 , 
346.19740135 , 
292.47613493 , 
357.83152562 , 
292.23860148 , 
357.60484370 , 
289.57363939 , 
354.94248484 , 
289.44535250 , 
354.80053188 , 
65.63149836 , 
345.61732225 , 
65.47087387 , 
345.45605574 , 
63.44784912 , 
343.41423549 , 
63.35907452 , 
343.33946853 , 
291.88936398 , 
357.24975643 , 
291.82485880 , 
357.18068629 , 
289.76967452 , 
355.12668049 , 
289.67175306 , 
355.02861632 , 
281.55530712 , 
352.35261810 , 
281.42439968 , 
352.24938327 , 
278.97981410 , 
350.02719015 , 
278.85510437 , 
349.92133810 , 
22.00377553 , 
316.56980860 , 
21.90517279 , 
316.46284837 , 
19.75021047 , 
314.30813547 , 
19.65168068 , 
314.22251157 , 
61.82307869 , 
342.35895286 , 
61.72775083 , 
342.26932522 , 
76.34806197 , 
76.04606111 , 
72.78104891 , 
72.57214405 ,    
]


FieldDec = [
    34.91428507 , 
37.49821880 , 
40.65042673 , 
40.68088709 , 
27.00669653 , 
46.03202996 , 
26.92009214 , 
45.95009008 , 
35.85564832 , 
36.07549446 , 
33.21539340 , 
33.46588854 , 
35.73138826 , 
35.98466807 , 
34.09748500 , 
34.12267170 , 
34.09294203 , 
34.13893991 , 
36.61585328 , 
36.66478027 , 
46.46868380 , 
46.46994247 , 
43.51347851 , 
43.51624997 , 
43.66300104 , 
43.66348065 , 
46.70418801 , 
46.70118660 , 
23.97273877 , 
24.01560920 , 
21.09411120 , 
21.10533290 , 
21.20763067 , 
21.23116518 , 
24.20600299 , 
24.24552495 , 
24.68008232 , 
24.68828668 , 
21.79641168 , 
21.80530300 , 
21.73794346 , 
21.74559895 , 
24.54397657 , 
24.55365301 , 
41.65664121 , 
33.64503727 , 
38.78528189 , 
30.76511927 , 
38.71817067 , 
30.70542493 , 
41.51971929 , 
33.51816389 , 
30.43793984 , 
30.40714378 , 
27.57033865 , 
27.53419146 , 
27.51145919 , 
27.48262013 , 
30.30734453 , 
30.28771515 , 
27.50060477 , 
27.47784368 , 
30.27953470 , 
30.27998842 , 
57.07703020 , 
54.33141096 , 
54.26313390 , 
57.01579872 , 
]
%

