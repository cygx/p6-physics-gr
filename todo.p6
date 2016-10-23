class Term {
    method Numeric { $!pows ?? NaN !! $!pre }

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

sub expr(*@terms) { Expr.new(:@terms) }

multi infix:<*>(Term $a, Term $b) { Term.mul($a, $b) }
multi prefix:<->(Term $a) { $a.neg }
