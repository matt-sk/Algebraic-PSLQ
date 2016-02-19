APSLQ := module()
export APSLQ, SetAffix, Info, AlgExpand, AlgTrm;
local term2mono, AlgSqrt, AlgCoeff, AlgAbs, AlgConj, AlgInvert, AlgDivide, AlgNearest, algbs, pp, AlgSqrt2, GetAllAlgebraics;
      
#Do not tab out $include's
$include "APSLQ.mpl";
$include "rootof.mpl";
    
    SetAffix := proc( )
    local i;
        for i from 1 to nargs do
            pp[i] := args[i];
        end do;
        pp := convert(pp,list);
        return NULL;
    end proc;
    
    Info := proc()
    local p;
        printf("\nINFO  :  ring is QQ[");
        for p in pp[1..-2] do
            printf("sqrt(%a), ", p);
        end do;
        printf("sqrt(%a)]\n", pp[-1]);
        printf("      :  precision is %a digits\n ",Digits);
        printf("\n");
    end proc;
    
end module: