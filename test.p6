use lib 'lib';
use Physics::GR;

#say GR.tensor(:sig<cc>, :2dim).set((0, 1, 42));
#say GR.unit-matrix(2) * GR.term(:x(4), :y(-1));
put GR.func(<f>, <x y>).diff(:x).MUL(2).MUL(GR.term(:x)).MUL(GR.func(<g>, <t>));
