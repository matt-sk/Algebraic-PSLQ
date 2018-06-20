APSLQ := module apslq()
	export APSLQ, GetDiagnostics, SetProfiling, GetProfile;
	local Initialise, AlgNearest, omega, nOmega, sqrtD, nSqrtD, minyTable, significance, diagWarning, ProfileQ;
	uses CodeTools[Profiling];

	Initialise := proc( D::integer )

		# Initialise the diagnostic elements.
		minyTable := table();
		significance := infinity;
		diagWarning := false;

		sqrtD := sqrt(abs(D));
		nSqrtD := evalf( sqrtD );

		if (D = 0) or (D = 1) or (D mod 4 = 2) or (D mod 4 = 3) then
			omega := sqrt(D);
		elif (D mod 4 = 1) then
			omega := (1+sqrt(D))/2;
		else
			error "D mod 4 = 0";
		end if;

		nOmega := evalf( omega );

		return NULL;
	end proc;

	ProfileQ := false;
	SetProfiling := proc( profile_q )
		if ProfileQ <> profile_q then
			ProfileQ := profile_q;
			if profile_q then
				Profile(APSLQ, AlgNearest);
			else
				UnProfile(APSLQ, AlgNearest);
			end if;
		end if;

		return NULL;
	end proc;

	GetProfile := proc( )
		if ProfileQ then
	   		return PrintProfiles( APSLQ, AlgNearest, output=string );
	   	else
	   		return "";
	   	end if;
	end proc;

	minyTable := table();
	significance := infinity;
	diagWarning := false;

	GetDiagnostics := proc()
		return table( [miny=convert( minyTable, list), sig=significance, warning=diagWarning] ); 
	end proc;

	AlgNearest := proc( x::complex, D::integer, $ )::algebraic;
		local alpha, beta, a, b, candidates, distance;
	    
	    alpha := Re(x);
	    beta  := Im(x);
	    
	    if -D = 0 or -D = 1 then
	        a := round(alpha);
	        b := 0;
	    elif -D mod 4 = 1 then
	        b := floor( 2*beta/nSqrtD );
	        a := alpha-0.5*b;

	        a := round( a ), round( a - 0.5 );

	        candidates := [ a[1] + b*nOmega, a[2] + (b+1)*nOmega ];
	        # Calculate square distance (we only need to find the minimum, so the square is fine, and less computationally intensive.
	        distance := map( z->(Re(z)*Re(z))+(Im(z)*Im(z)), candidates -~ x );

	        if is(distance[1] <= distance[2]) then
	            a := a[1];
	        else
	            a,b := a[2], b+1;
	        end if;               
	    else
	        a := round( alpha );      
	        b := round( beta/nSqrtD );
	    end if;
	    
	    return a + b*omega;
	    
	end proc:

	# Main APSLQ Function Implementation
	APSLQ := proc( xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::nonnegint, { iterations := 1000, digits := 100, gmma :=  2/sqrt(3),  threshold := 10^( -trunc(.24*digits) ) }, $)::list(integer);

		description "APSLQ over Q[sqrt(-D)]";
		local A, B, H, ii, i, j, k, n, s, t, tf, yy, m, M, maxy, miny, prev_miny, pos, prev_m := 1, tmp, candidateRelation, gg, delta, beta, lambda;
		uses LinearAlgebra;

	    # Perform module initialisation for an instance of Q(sqrt(-D)).
	    #  ... this sets up the sqrtD, nSqrtD, omega and nOmega module variables.
	    Initialise( -D );
	    prev_miny := infinity;

	    # Set the local precision.
	    if Digits > digits then WARNING("APSLQ is using lower precision than session."); fi;  
	    Digits := digits;

	    # Evaluate xx as floating point, and create a new Vector from it.
	    yy := Vector( map(evalf, xx, digits) ); #, datatype=complex(sfloat) );

	    # Normalize the input.
	    Normalize( yy, Euclidean, inplace=true );

	    # Set the number size of the APSLQ instance (the number of input values). 
	    n := Dimension(yy):

	    # Pre compute the array of gamma^k for 1 ≤ k ≤ n-1
	    gg := Array( 1..(n-1) );
	    gg[1] := evalf(gmma);
	    for i from 2 to n-1 do gg[i] := gg[1]*gg[i-1] od; 

	    # PSLQ Initialization

	    # The B matrix is an algebraic integer valued matrices with the property that for each column vector, col, of B:
	    #   col[1]*xx[1] + ... + col[n]*xx[n] = yy[n].
	    B := IdentityMatrix( n, compact = false ): # Must use compact=false so that we may modify the contents of the matrix later.

	    # Check for trivial identity.
	    pos := min[index]( map(abs,yy) );
	    miny := abs( yy[pos] );
	    if miny < threshold then # No need to normalize because B is the identity matrix, so miny / ||Col(B,pos)|| = miny.
	        return convert( Column(B, pos), list );
	    end if;

	    s := Vector( n );
	    for k from 1 to n do
	        s[k] := add( yy[j]*conjugate(yy[j]), j=k..n );
	        s[k] := sqrt(s[k]);
	    end do:
	            
	    H := Matrix( n, n-1 );
	    for j from 1 to n-1 do
	        for i from 1 to j-1 do
	            H[i,j] := 0;
	        end do;
	        
	        H[j,j] := s[j+1]/s[j];
	        
	        for i from j+1 to n do 
	            H[i,j] := -conjugate(yy[i])*yy[j]/s[j]/s[j+1];
	        end do;
	    end do:
	        
	    #Reduce H
	    for i from 2 to n do
	        for j from i-1 to 1 by -1 do
	            t := AlgNearest( H[i,j]/H[j,j], D );
	            tf := eval( t, sqrtD = nSqrtD ); # Tests indicate that this is the fastest way to  compute the floating point value of t.

	            yy[j] := yy[j] + tf*yy[i];
	            
	            for k from 1 to j do
	                H[i,k] := H[i,k] - tf*H[j,k];
	            end do;
	            
	            for k from 1 to n do
	                B[k,j] := expand( B[k,j] + t*B[k,i] );
	            end do;
	        end do;
	    end do:

	    for ii from 1 to iterations do
	        #ITERATION
	        m, t := 0, 0.0:
	        
	        for i from 1 to n-1 do
	            if i = prev_m then next; fi;
	            if t < gg[i]*abs( H[i,i] ) then
	                t := gg[i]*abs( H[i,i] );
	                m := i;
	            end if;
	        end do:
	        
	        # Record this value of m as prev_m for the next iteration.
	        prev_m := m;

	        # Swap Rows & Columns (as appropriate)
	        if m = n then
	            error "ran out of row swaps";
	        end if; 
	        
	        yy[m], yy[m+1] := yy[m+1], yy[m] :
	        
	        LinearAlgebra[RowOperation]( H, [m,m+1], inplace=true):
	        LinearAlgebra[ColumnOperation]( B, [m,m+1], inplace=true):
	        
	        # Remove corner on H diagonal
	        # Variables named to be in keeping with the Ferguson, Bailey and Arno paper.
	        # Note that the definitions fo these constants are modified to be correct *after* the row swap
	        # (they are defined in terms of the pre-swapped matrix in the paper)
	        if m <= n-2 then
	            delta := sqrt( H[m,m]*conjugate(H[m,m]) + H[m,m+1]*conjugate(H[m,m+1]) );
	            beta := H[m,m];
	            lambda := H[m,m+1];
	            for i from m to n do
	                # We update both H[i,m] and H[i,m+1], however each update requires the ounupdated value of the other.
	                # So we save the unmodified values before proceeding.
	                t := H[i,m],H[i,m+1];
	                H[i,m]   :=  t[1]*conjugate(beta)/delta + t[2]*conjugate(lambda)/delta;
	                H[i,m+1] := -t[1]*lambda/delta + t[2]*beta/delta;
	            end do:
	        end if:
	        
	        #Reduce H
	        for i from m+1 to n do
	            for j from min(i-1,m+1) to 1 by -1 do
	                t := AlgNearest( H[i,j]/H[j,j], D );
	                tf := eval( t, sqrtD = nSqrtD ); # Tests indicate that this is the fastest way to  compute the floating point value of t.

	                yy[j] := yy[j] + tf*yy[i];
	                
	                for k from 1 to j do
	                    H[i,k] := H[i,k] - tf*H[j,k];
	                end do;
	                
	                for k from 1 to n do
	                    B[k,j] := expand( B[k,j] + t*B[k,i] );
	                end do;
	            end do;
	        end do;
	        
	        #NORM BOUND
	        M := 0:
	        for j from 1 to n-1 do
	            if abs(eval(1/H[j,j])) > M then
	                M := abs(eval(1/H[j,j]));
	            end if;
	        end do:

	        # Find the smallest magnitude yy value (which is our smallest linear combination value) and record it in the execution history.
	        pos := min[index]( map(abs, yy) );
	        miny := abs( yy[pos] );
	        minyTable[ii] := miny; # Save diagnosis information.

	        # Check only for a new relation if the current miny is strictly smaller than the previous one.
	        if miny < prev_miny then
	            prev_miny := miny;
	            candidateRelation := Column(B, pos);

	            # Check to see if the smallest linear combination is below our threshold for “0” (after normalisation of the B column vector)
	            if miny/evalf(VectorNorm(candidateRelation,Euclidean)) < threshold then
	                yy := map( abs, yy );
	                maxy := max( yy );
	                significance := [ evalf[2](threshold/maxy), evalf[2](miny/maxy) ];
	                return convert( candidateRelation, list );
	            end if;
	        end if;

	        # Check for diagonal element equal to “Zero”.  (I think this should be caught by the if block immediately above) 
	        if abs(H[n-1,n-1]) < threshold then
	            WARNING( "Found relation due to H[n-1,n-1]=0, which somehow got missed by the miny check." );
	            diagWarning := true;
	            miny, pos := abs( yy[n-1] ), n-1;
	            maxy := max( map(abs, yy) );
	            significance := [ evalf[2](threshold/maxy), evalf[2](miny/maxy) ];
	            return convert( candidateRelation, list );
	        end if;

	        # H[i,i] = 0 should only be possible for i = n-1. However, *PERHAPS* it can happen for i ≠ n-1 due to unforseen numeric circumstances.
	        for i from 1 to n-2 do
	            if abs(H[i,i]) = 0. then error "Diagonal element of H is 0." end if;
	            if abs(H[i,i]) < threshold then diagWarning := true; end if;
	        end do;
	    end do:
	    
	    return FAIL;
	end proc;

end module;