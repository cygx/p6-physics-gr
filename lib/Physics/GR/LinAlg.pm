unit module Physics::GR::LinAlg;

enum IndexType is export <COVARIANT CONTRAVARIANT>;

role Tensor is export {
    method rank { ... }
    method shape { ... }
    method type { ... }
    method dimension { ... }
    method AT-POS(|) { ... }
    method EXISTS-POS(|) { ... }
    proto method MULTIPLY($) {*}
    proto method RMULTIPLY($) {*}
    multi method MULTIPLY($a: $b) is hidden-from-backtrace {
        fail "Don't know how to multiply {$a.^name} and {$b.^name}";
    }
    multi method RMULTIPLY($b: $a) is hidden-from-backtrace {
        fail "Don't know how to multiply {$a.^name} and {$b.^name}";
    }
}

class Scalar_ { ... }
class Vector { ... }
class Covector { ... }
class Matrix { ... }
class HomogeneousTensor { ... }

class Scalar_ does Tensor is export {
    has $.value;
    method Numeric {
        $!value ~~ Numeric
            ?? $!value
            !! fail "Scalar of type {$!value.^name} is not numeric";
    }
    method new($value) { self.bless(:$value) }
    multi method gist(::?CLASS:D:) { "scalar({ $!value.gist })" }
    method Str { $!value ~~ Real ?? ~$!value !! "({$!value})" }
    method rank { 0 }
    method shape { () }
    method type { () }
    method dimension { 0 }
    method AT-POS(|) { !!! }
    method EXISTS-POS(|) { !!! }
    multi method MULTIPLY(Scalar_ $s) { Scalar_.new($!value * $s.value) }
    multi method MULTIPLY(Numeric $x) { Scalar_.new($!value * $x) }
    multi method RMULTIPLY(Scalar_ $s) { Scalar_.new($!value * $s.value) }
    multi method RMULTIPLY(Numeric $x) { Scalar_.new($!value * $x) }
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
    multi method MULTIPLY(Scalar_ $s) {
        self.new($!components.elems, $!components.map(* * $s.value));
    }
    multi method MULTIPLY(Numeric $x) {
        self.new($!components.elems, $!components.map(* * $x));
    }
    multi method RMULTIPLY(Scalar_ $s) {
        self.new($!components.elems, $!components.map($s.value * *));
    }
    multi method RMULTIPLY(Numeric $x) {
        self.new($!components.elems, $!components.map($x * *));
    }
}

class Vector does Vectorial[CONTRAVARIANT] is export {
    multi method gist(::?CLASS:D:) {
        "vector({ $!components.map(*.gist).join(', ') })";
    }
    multi method RMULTIPLY(Covector $v) {
        Scalar_.new([+] self.components Z* $v.components);
    }
}

class Covector does Vectorial[COVARIANT] is export {
    multi method gist(::?CLASS:D:) {
        "covector({ $!components.map(*.gist).join(', ') })";
    }
    multi method MULTIPLY(Vector $v) {
        Scalar_.new([+] self.components Z* $v.components);
    }
}

sub mat($m, $n, @tuples) {
    my @mat = [0 xx $n] xx $m;
    for @tuples -> ($i, $j, $v) {
        @mat[$i;$j] = $v;
    }
    @mat;
}

class Matrix does Tensor is export {
    has $.elements;
    has $.dimension;
    method new(Int $m, Int $n, @init = (0 xx $n) xx $m) {
        my @m[$m;$n] = @init>>.list;
        self.bless(
            dimension => $m == $n ?? $m !! NaN,
            elements => @m,
        );
    }
    method unit(Int $n) {
        self.new($n, $n, mat($n, $n, (^$n Z ^$n Z 1 xx *)));
    }
    method rank { 2 }
    method shape { $!elements.shape }
    method type { (CONTRAVARIANT, COVARIANT) }
    method AT-POS(|c) { $!elements.AT-POS(|c) }
    method EXISTS-POS(|c) { $!elements.EXISTS-POS(|c) }
    multi method MULTIPLY($a: Matrix $b) {
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
    multi method MULTIPLY(Vector $v) {
        PRE self.shape[1] == $v.dimension;
        my (\M, \N) = self.shape;
        Vector.new();
    }
}

class HomogeneousTensor does Tensor is export {
    has $.elements;
    has $.dimension;
    has $.type;
    has $.shape;
    has $.rank;
    method AT-POS(|) { !!! }
    method EXISTS-POS(|) { !!! }    
}

sub scalar($value) is export { Scalar_.new($value) }
sub vector(*@init) is export { Vector.new(@init.elems, @init) }
sub covector(*@init) is export { Covector.new(@init.elems, @init) }
sub matrix(**@init) is export { Matrix.new(@init.elems, @init[0].elems, @init) }
sub row-matrix(*@row) is export { Matrix.new(1, @row.elems, [@row,]) }
sub col-matrix(*@col) is export { Matrix.new(@col.elems, 1, @col.map({ [$_] })) }
sub unit-matrix(Int $n) is export { Matrix.unit($n) }

multi infix:<*>(Tensor $a, Tensor $b) is export {
    $a.MULTIPLY($b) // $b.RMULTIPLY($a);
}
multi infix:<*>(Tensor $a, $b) is export { $a.MULTIPLY($b) }
multi infix:<*>($a, Tensor $b) is export { $b.RMULTIPLY($a) }

multi infix:<(x)>(Tensor $a, Tensor $b) is export { ... }
