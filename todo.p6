class Matrix {
    method row(Int $i) {
        gather {
            for ^$.shape[1] -> $j {
                take $!entries[$i;$j];
            }
        }
    }

    method col(Int $j) {
        gather {
            for ^$.shape[0] -> $i {
                take $!entries[$i;$j];
            }
        }
    }

    method mul(Matrix $a, Matrix $b) {
        PRE $a.shape[1] == $b.shape[0];
        my \M = $a.shape[0];
        my \N = $b.shape[1];
        my $c := Matrix.new(M, N);
        for ^M -> $i {
            for ^N -> $j {
                $c[$i;$j] = [+] $a.row($i) Z* $b.col($j);
            }
        }
        $c;
    }
}

class Term {
    has Numeric $.pre;
    has Mix $.pows;

    method Numeric { $!pows ?? NaN !! $!pre }

    multi method gist(Term:D:) {
        my $pre = do given $!pre {
            when 1 { '' }
            when -1 { '-' }
            when Real { "$_ " }
            default { "($_) " }
        }
        my $pows = $!pows.keys.sort.map: {
            $_ ~ ($_ == 1 ?? '' !! "^$_" given $!pows{$_});
        }
        $pre ~ $pows;
    }

    method neg { Term.new(:pre(-$!pre), :$!pows) }

    method mul(Term $a, Term $b) {
        Term.new(:pre($a.pre * $b.pre), :pows($a.pows (+) $b.pows))
    }

    multi method diff(Str $var where not $!pows{$var}) { 0 }
    multi method diff(Str $var where $!pows.elems == 1 && $!pows{$var} == 1) {
        $!pre;
    }
    multi method diff(Str $var) {
        Term.new(:pre($!pre * $!pows{$var}), :pows($!pows (+) ($var => -1).Mix));
    }
}

class Expr {
    has @.terms;

    method diff(Str $var) {
        my @terms = @!terms.map: {
            given .diff($var) {
                when 0 { Empty }
                default { $_ }
            }
        }
        @terms ?? Expr.new(:@terms) !! 0;
    }

    multi method gist(Expr:D:) {
        @!terms.map($_).join(' + ') given {
            .pre ~~ Real && .pre < 0 ?? "({.gist})" !! .gist;
        }
    }
}

sub term(Numeric $pre = 1, *%_) {
    Term.new(:$pre, :pows(%_.map({ .key => +.value }).Mix));
}

sub expr(*@terms) { Expr.new(:@terms) }

multi infix:<*>(Term $a, Term $b) { Term.mul($a, $b) }
multi infix:<*>(Matrix $a, Matrix $b) { Matrix.mul($a, $b) }
multi prefix:<->(Term $a) { $a.neg }
