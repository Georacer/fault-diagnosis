Jx = 0.8244;
Jy = 1.135;
Jz = 1.759;
Jxz = 0.1204;

G = Jx*Jz - Jxz*Jxz
G1 = Jxz*(Jx - Jy + Jz)/G
G2 = (Jz*(Jz - Jy) + Jxz*Jxz)/G
G3 = Jz/G
G4 = Jxz/G
G5 = (Jz - Jx)/Jy
G6 = Jxz/Jy
G7 = ((Jx - Jy)*Jx + Jxz*Jxz)/G
G8 = Jx/G