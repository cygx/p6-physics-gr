use lib 'lib';
use Physics::GR;

say gr.tensor(<cc>, :2dim).set((0, 1, 42));
say gr.unit-matrix(2) * gr.term(:x(4), :y(-1));
put gr.func(<f>, <x y>).diff(:x).diff(:y) * 2;
