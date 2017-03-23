syms Dnorth Deast Ddown phi theta psi u v w chi;
fkin1 = -Dnorth + (cos(theta)*cos(psi))*u + (-cos(phi)*sin(psi)+sin(phi)*sin(theta)*cos(psi))*v + (sin(phi)*sin(psi)+cos(phi)*sin(theta)*cos(psi))*w;
fkin2 = -Deast + (cos(theta)*sin(psi))*u + (cos(phi)*cos(psi) + sin(phi)*sin(theta)*sin(psi))*v + (-sin(phi)*cos(psi) + cos(phi)*sin(theta)*sin(psi))*w;
fkin3 = -Ddown + (-sin(theta))*u + (sin(phi)*cos(theta))*v + (cos(phi)*cos(theta))*w;
fkin4 = -chi + atan2(Deast, Dnorth);

syms Dphi Dtheta Dpsi phi theta psi p q r;
fkin5 = -Dphi + p + tan(theta)*sin(phi)*q + tan(theta)*cos(phi)*r;
fkin6 = -Dtheta + cos(phi)*q - sin(phi)*r;
fkin7 = -Dpsi + sin(phi)/cos(theta)*q + cos(phi)*cos(theta)*r;

syms Dp Dq Dr Gamma Jxz Jx Jy Jz p q r Tx Ty Tz;
fkin8 = -Dp + 1/Gamma*(Jxz*(Jx-Jy+Jz)*p*q - (Jz*(Jz-Jy)+Jxz*Jxz)*q*r + Jz*Tx + Jxz*Tz);
fkin9 = -Dq + 1/Jy*((Jz-Jx)*p*r - Jxz*(p*p-r*r) + Ty);
fkin10 = -Dr + 1/Gamma*(((Jx - Jy)*Jx + Jxz*Jxz)*p*q - Jxz*(Jx - Jy + Jz)*q*r + Jxz*Tx + Jx*Tz);
fkin11 = -Gamma +Jx*Jz - Jxz*Jxz;

syms Du Dv Dw u v w p q r Fx Fy Fz m;
fkin12 = -Du + r*v - q*w + Fx/m;
fkin13 = -Dv -r*u + p*w + Fy/m;
fkin14 = -Dw +q*u - p*v + Fz/m;

syms u v w ur vr wr uw vw ww alpha beta Va;
fkin15 = -ur + u - uw;
fkin16 = -vr + v - vw;
fkin17 = -wr + w - ww;
fkin18 = -ww;
fkin19 = -alpha + atan2(wr, ur);
fkin20 = -beta + asin(vr/Va);
fkin21 = -Va + sqrt(ur*ur + vr*vr + wr*wr);

syms m mmon merr pcgx pcgy pcgz perrx perry perrz;
fkin22 = -m + mnom + merr;
fkin23 = -pcgx + 1/m*perrx*merr;
fkin24 = -pcgy + 1/m*perry*merr;
fkin25 = -pcgz + 1/m*perrz*merr;
fkin26 = -merr;

syms Fx Fy Fz Fgx Fgy Fgz Fax Fay Faz Ftx Fty Ftz Tx Ty Tz Tax Tay Taz Ttx Tty Ttz
dyn1 = -Fx + Fgx + Fax + Ftx;
dyn2 = -Fy + Fgy + Fay + Fty;
dyn3 = -Fz + Fgz + Faz + Ftz;
dyn4 = -Tx + Taxt + Ttxt;
dyn5 = -Ty + Tayt + Ttyt;
dyn6 = -Tz + Tazt + Ttzt;

syms Fgx Fgy Fgz phi theta m g;
dyn7 = -Fgx -sin(theta)*m*g;
dyn8 = -Fgy + sin(phi)*cos(theta)*m*g;
dyn9 = -Fgz + cos(phi)*cos(theta)*m*g;

syms Fax Fay Faz alpha beta FD FY FL
dyn10 = - Fax -cos(alpha)*FD - cos(alpha)*sin(beta)*FY + sin(alpha)*FL;
dyn11 = - Fay -sin(beta)*FD + cos(beta)*FY;
dyn12 = - Faz -sin(alpha)*cos(beta)*FD - sin(alpha)*sin(beta)*FY - cos(alpha)*FL;

syms Taxt Tayt Tazt Tax Tay Taz pcgx pcgy pcgz pclx pcly pclz Fax Fay Faz
dyn13 = -Taxt + Tax - (pclz-pcgz)*Fay + (pcly-pcgy)*Faz;
dyn14 = -Tayt + Tay + (pclz-pcgz)*Fax - (pclx-pcgx)*Faz;
dyn15 = -Tazt + Taz - (pcly-pcgy)*Fax + (pclx-pcgx)*Fay;
dyn16 = -pclx;
dyn17 = -pcly;
dyn18 = -pclz;

syms qbar rho Va;
dyn19 = -qbar + 0.5*rho*Va*Va;

syms FD FY FL S CD CY CL qbar
dyn20 = -FD + qbar*S*CD;
dyn21 = -FY + qbar*S*CY;
dyn22 = -FL + qbar*S*CL;

S = 
b = 
c = 
syms Tax Tay Taz qbar Cl Cm Cn;
dyn23 = -Tax + qbar*S*b*Cl;
dyn24 = -Tay + qbar*S*c*Cm;
dyn25 = -Taz + qbar*S*b*Cn;

CD0 = 
CDa = 
CDq = 
CDde = 
CY0 = 
CYb = 
CYp = 
CYr = 
CYda = 
CYdr = 
CL0 = 
CLa = 
CLq = 
CLde = 
Cl0 = 
Clb = 
Clp = 
Clr = 
Clda = 
Cldr = 
Cm0 = 
Cma = 
Cmq = 
Cmde = 
Cn0 = 
Cnb = 
Cnp = 
Cnr = 
Cnda = 
Cndr = 

syms CD CY CL Cl Cm Cn Va alpha beta p q r deltaa deltae deltar;
dyn26 = -CD + CD0 + CDa*alpha + CDq*c*q/2/Va + CDde*deltae;
dyn27 = -CY + CY0 + CYb*beta + CYp*b*p/2/Va + CYr*b*r/2/Va + CDda*deltaa + CYdr*deltar;
dyn28 = -CL + CL0 + CLa*alpha + CLq*c*q/2/Va + CLde*deltae;
dyn29 = -Cl + Cl0 + Clb*beta + Clp*b/p/2/Va + Clr*b*r/2/Va + Clda*deltaa + Cldr*deltar;
dyn30 = -Cm + Cm0 + Cma*alpha + Cmq*c*q/2/Va + Cmde*deltae;
dyn31 = -Cn + Cn0 + Cnb*beta + Cnp*b*p/2/Va + Cnr*b*r/2/Va + Cnda*deltaa + Cndr*deltar;

syms Ftx Fty Ftz Ttxt Ttyt Ttzt Ttx Tty Ttz pcgx pcgy pcgz pprx ppry pprz;
dyn32 = -Fty;
dyn33 = -Ftz;
dyn34 = -Ttxt + Ttx - (pprz - pcgz)*Fty + (ppry - pcgx)*Ftz;
dyn35 = -Ttyt + Tty + (pprz - pcgz)*Ftx - (pprx - pcgx)*Ftz;
dyn36 = -Ttzt + Ttz - (ppry - pcgy)*Ftx - (pprx - pcgx)*Fty;
dyn37 = -pprx;
dyn38 = -ppry;
dyn39 = -pprz;
dyn40 = -Tty;
dyn41 = -Ttz;

D = 
syms Ftx Ct rho n Jar Va;
dyn42 = -Ftx + Ct*rho*n*n*D^4;
dyn43 = -Jar + Va/n/D;
dyn44 = -Ct completeme

syms Pp Cp rho n Jar 