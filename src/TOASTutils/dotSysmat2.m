function S = dotSysmat2(hmesh, mua, musp, n)
% compute S matrix for CW with kap = 1/(3mus) and 'Contini' Boundary term
c = 0.299./n;
c = ones(size(c));
kap = 1./(3*musp);
alpha = toastDotBndterm(n,'Contini');
S1 = hmesh.SysmatComponent('PFF',mua.*c);  % absorption term
S2 = hmesh.SysmatComponent('PDD',kap.*c);  % diffusion component
S3 = hmesh.SysmatComponent('BndPFF',c./(2*alpha)); % boundary term
S = S1 + S2 + S3;