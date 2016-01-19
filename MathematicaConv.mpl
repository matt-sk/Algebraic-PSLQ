interface(quiet=true):

Nearest := proc( x::{algebraic,complex} )::algebraic;
    
    if type(x,float) then
        return round(x);
    elif type(x,complex) then
        return GaussInt[GInearest](x);
    end if;
    
    error "Nearest did not return";
end proc:

PSLQ := proc( in_xx::list(complex(extended_numeric)), Q::posint, {iterations:=500, digits:=20})::list({integer,algebraic});
#option trace;
local xx, n, gam, AA, BB, ss, yy, HH, i, j, t, k, it, miny, r, mx, TT, d, M, sqrtQ, m;
    
    Digits := digits;
    sqrtQ  := sqrt(Q);
    
    xx := in_xx;
    n  := nops(xx);
    
    gam := sqrt(4./3);
    
    AA := LinearAlgebra[IdentityMatrix](n,compact=false);
    BB := LinearAlgebra[IdentityMatrix](n,compact=false);
    
    ss := [seq( sqrt(add(xx[i]^2,i=k..n)), k=1..n)];
    
    yy := map( x -> x/ss[1], xx);
    ss := map( s -> s/ss[1], ss);
    
    HH := LinearAlgebra[ZeroMatrix](n,n-1,compact=false);
    
    
    for i from 1 to n-1 do 
        HH[i,i] := ss[i+1]/ss[i];
    end do;
    
    for i from 1 to n do
        for j from 1 to i-1 do
            HH[i,j] := -yy[i]*yy[j]/ss[j]/ss[j+1];
        end do;
    end do;
    
    for i from 2 to n do
        for j from i-1 to 1 by -1 do
            t := Nearest(Re( HH[i,j]/HH[j,j] )) + Nearest(Im(HH[i,j]/HH[j,j])/sqrtQ)*sqrtQ*I;
            yy[j] := evalc( yy[j] + t*yy[i] );
            
            for k from 1 to j do
                HH[i,k] := HH[i,k] - t*HH[j,k];
            end do;
            
            for k from 1 to n do 
                AA[i,k] := AA[i,k] - t*AA[j,k];
                BB[k,j] := BB[k,j] + t*BB[k,i];
            end do;
        end do; 
    end do;

#t  := t;
#HH := HH;
#AA := AA;
#BB := BB;
#ss := ss;
#yy := yy;
#stop;
    
    #while loop
    for it from 0 to iterations do
        
        miny := min(map(abs,evalf(yy)));
        if miny <= 1/10^digits then
            break;
        end if;
        
        r  := 1;
        mx := 0;
        
        
        for i from 1 to n-1 do
HH[i,i] := simplify( HH[i,i] );
            if gam^i*abs(HH[i,i]) > mx then
                mx := gam^i * abs( HH[i,i] );
                r  := i;
            end if;
        end do;
        
        yy[r], yy[r+1] := yy[r+1], yy[r];
        AA[r], AA[r+1] := AA[r+1], AA[r];
        HH[r], HH[r+1] := HH[r+1], HH[r];
        
        BB := LinearAlgebra[Transpose]( BB );
        BB[r], BB[r+1] := BB[r+1], BB[r];
        BB := LinearAlgebra[Transpose]( BB );
        
        TT := [0,0,0,0];
        
        if r <= n-2 then
            d     := sqrt(HH[r,r]^2 + HH[r,r+1]^2 );
            TT[1] := HH[r,r]/d;
            TT[2] := HH[r,r+1]/d;
            
            for i from r to n do
                TT[3]     := HH[i,r];
                TT[4]     := HH[i,r+1];
                HH[i,r]   := TT[1]*TT[3] + TT[2]*TT[4];
                HH[i,r+1] := -TT[2]*TT[3] + TT[1]*TT[4];
            end do;
        end if;
        
        for i from r + 1 to n do
            for j from min(i-1,r+1) to 1 by -1 do
                t := Nearest(Re(HH[i,j]/HH[j,j])) + Nearest(Im(HH[i,j]/HH[j,j])/sqrtQ)*sqrtQ*I;
                yy[j] := evalc( yy[j] + t*yy[i] );
                
                for k from 1 to j do
                    HH[i,k] := HH[i,k] - t*HH[j,k];
                end do;
                
                HH := map( simplify, HH );
                
                
                for k from 1 to n do
                    AA[i,k] := AA[i,k] - t*AA[j,k];
                    BB[k,j] := BB[k,j] + t*BB[k,i];
                end do;
                
            end do;
        end do;
        
        M := 1 / max( seq( map(abs,HH[i]), i=1..n) );
        
    end do;
    
    m := min( map(abs,evalf(yy)) );
#    if m > 1/10^digits then
#        error "No relation vector with norm less than %1", M;
#    end if;
    
    miny, pos := ListTools[FindMinimalElement]( map(abs,yy), position );
    
    return convert( LinearAlgebra[Column]( BB, pos ), list );
end proc:

alpha[1] := 8.5557740294193677145942152523917120406963393361912326584326092225892073004511968596795229586699088861323020971088473562289297701621336866915814018227972660826234785 + 19.5245199789778207252709649000355636736293248679379812876485209200681378501683637447418153530412133861344645065764304799255945701193060988563269844700085446896322031*I:
alpha[2] := 240.2580715512005850377991641860749049037349215083857742661467434047260038067178950809318221943327582161743869784010182847623831977533217181552096871784099275510000929 - 197.7231299819772360738201009482325219970251881102166481443122240054056135688592625739072692028291163278533468709595297851879697973293924262946187211177789954254215274*I:

xx := [Re(alpha[1]), 1, evalf(Pi), ln(2.)]:
mm := PSLQ( xx, 5, iterations=500, digits=100 ):

add( xx[i]*mm[i], i = 1..nops(xx) );



quit;