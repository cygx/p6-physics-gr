unit package Physics::GR;
use Physics::GR::Categories;

multi infix:<*>(Symbolic $a, Symbolic $b) { $a.MUL($b) }
multi infix:<*>(Symbolic $a, Numeric $b) { $a.MUL($b) }
multi infix:<*>(Numeric $a, Symbolic $b) { $b.MUL($a) }

enum IndexType is export <COVARIANT CONTRAVARIANT>;

role Tensor does Algebraic is export {
    method rank { ... }
    method shape { ... }
    method type { ... }
    method dimension { ... }
    method AT-POS(|) { ... }
    method EXISTS-POS(|) { ... }
    method ASSIGN-POS(|) { ... }
    method set(**@args) {
        self.ASSIGN-POS(|$_) for @args;
        self;
    }
}

class Skalar { ... }
class Vector { ... }
class Covector { ... }
class Matrix { ... }
class HomogeneousTensor { ... }

class Skalar does Tensor is export {
    has $.value;
    method Numeric {
        $!value ~~ Numeric
            ?? $!value
            !! fail "Scalar of type {$!value.^name} is not numeric";
    }
    method new($value) { self.bless(:$value) }
    multi method gist(::?CLASS:D:) { "skalar({ $!value.gist })" }
    method Str { $!value ~~ Real ?? ~$!value !! "({$!value})" }
    method rank { 0 }
    method shape { () }
    method type { () }
    method dimension { 0 }
    method AT-POS(|) { !!! }
    method EXISTS-POS(|) { !!! }
    method ASSIGN-POS(|) { !!! }
    multi method MUL(Skalar $s) { Skalar.new($!value * $s.value) }
    multi method MUL(Numeric $x) { Skalar.new($!value * $x) }
    multi method MUL(Symbolic $x) { Skalar.new($!value * $x) }
    multi method RMUL(Skalar $s) { Skalar.new($!value * $s.value) }
    multi method RMUL(Numeric $x) { Skalar.new($!value * $x) }
    multi method RMUL(Symbolic $x) { Skalar.new($!value * $x) }
}

role Vectorial[\TYPE] does Tensor is export {
    has $.components;
    method new(Int $n, @init = 0 xx $n) {
        self.bless(components => my @[$n] = @init);
    }
    method rank { 1 }
    method shape { $!components.shape }
    method type { (TYPE,) }
    method dimension { $!components.elems }
    method AT-POS(|c) { $!components.AT-POS(|c) }
    method EXISTS-POS(|c) { $!components.EXISTS-POS(|c) }
    method ASSIGN-POS(|c) { $!components.ASSIGN-POS(|c) }
    multi method MUL(Skalar $s) {
        self.new($!components.elems, $!components.map(* * $s.value));
    }
    multi method MUL(Numeric $x) {
        self.new($!components.elems, $!components.map(* * $x));
    }
    multi method MUL(Symbolic $x) {
        self.new($!components.elems, $!components.map(* * $x));
    }
    multi method RMUL(Skalar $s) {
        self.new($!components.elems, $!components.map($s.value * *));
    }
    multi method RMUL(Numeric $x) {
        self.new($!components.elems, $!components.map($x * *));
    }
    multi method RMUL(Symbolic $x) {
        self.new($!components.elems, $!components.map($x * *));
    }
}

class Vector does Vectorial[CONTRAVARIANT] is export {
    multi method gist(::?CLASS:D:) {
        "vector({ $!components.map(*.gist).join(', ') })";
    }
    multi method RMUL(Covector $v) {
        Skalar.new([+] self.components Z* $v.components);
    }
}

class Covector does Vectorial[COVARIANT] is export {
    multi method gist(::?CLASS:D:) {
        "covector({ $!components.map(*.gist).join(', ') })";
    }
    multi method MUL(Vector $v) {
        Skalar.new([+] self.components Z* $v.components);
    }
}

class Matrix does Tensor is export {
    has $.elements;
    has $.dimension;
    method new(Int $m, Int $n, @init = (0 xx $n) xx $m) {
        my @m[$m;$n] = @init>>.list;
        self.bless(
            dimension => $m == $n ?? $m !! Int,
            elements => @m,
        );
    }
    method rank { 2 }
    method shape { $!elements.shape }
    method type { (CONTRAVARIANT, COVARIANT) }
    method AT-POS(|c) { $!elements.AT-POS(|c) }
    method EXISTS-POS(|c) { $!elements.EXISTS-POS(|c) }
    method ASSIGN-POS(|c) { $!elements.ASSIGN-POS(|c) }
    multi method MUL($a: Matrix $b) {
        PRE $a.shape[1] == $b.shape[0];
        my \K = $a.shape[1];
        my \M = $a.shape[0];
        my \N = $b.shape[1];
        Matrix.new($a.shape[0], $b.shape[1],
            (for ^M -> $i {
                (for ^N -> $j {
                    [+] ($a[$i;$_] * $b[$_;$j] for ^K);
                })
            })
        );
    }
    multi method MUL(Vector $v) {
        PRE self.shape[1] == $v.dimension;
        my (\M, \N) = self.shape;
        Vector.new(M, (for ^M -> $i {
            [+] ($!elements[$i;$_] * $v[$_] for ^N);
        }));
    }

    sub smul($m, $x) {
        my (\M, \N) = $m.shape;
        Matrix.new(M, N, (for ^M -> $i { (for ^N -> $j { $m[$i;$j] * $x }) }));
    }

    multi method MUL(Numeric $x) { smul(self, $x) }
    multi method MUL(Symbolic $x) { smul(self, $x) }
    multi method RMUL(Numeric $x) { smul(self, $x) }
    multi method RMUL(Symbolic $x) { smul(self, $x) }
}

class HomogeneousTensor does Tensor is export {
    has $.elements;
    has $.dimension;
    has $.type;
    method rank { $!type.elems }
    method shape { $!elements.shape }
    method AT-POS(|c) { $!elements.AT-POS(|c) }
    method EXISTS-POS(|c) { $!elements.EXISTS-POS(|c) }
    method ASSIGN-POS(|c) { $!elements.ASSIGN-POS(|c) }
}

role LinAlg is export {
    method skalar($value) { Skalar.new($value) }
    method vector(*@init) { Vector.new(@init.elems, @init) }
    method covector(*@init) { Covector.new(@init.elems, @init) }
    method matrix(**@init) { Matrix.new(@init.elems, @init[0].elems, @init) }
    method row-matrix(*@row) { Matrix.new(1, @row.elems, [@row,]) }
    method col-matrix(*@col) { Matrix.new(@col.elems, 1, @col.map({ [$_] })) }
    method unit-matrix(Int $n) {
        Matrix.new($n, $n).set(|(^$n Z ^$n Z 1 xx *));
    }
    multi method tensor(Str :$sig!, Int :$dim!) {
        my $type := $sig.comb.map({
            when 'c' { COVARIANT }
            when 'k' { CONTRAVARIANT }
            default { die "Illegal tensor signature '$_'" }
        }).list;
        my $dimension := $dim;
        my $rank := $type.elems;
        my $shape := ($dim xx $rank).list;
        my $elements := Array.new(:$shape, $_) given do {
            my $init := 0;
            $init := $init xx $dim for ^$rank;
            $init;
        }
        HomogeneousTensor.new(:$elements, :$dimension, :$type);
    }
}
