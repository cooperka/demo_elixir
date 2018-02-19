all Elixir data types:

Atom/Sym  String          :"Elixir.String"
BitString ""
Float     1.0
Function  fn -> :result end
Integer   1
List      []
Map       %{}
PID       #PID<0.44.0>    self()
Port      #Port<0.1444>
Reference &length/1
Tuple     {}

users = [
  john: %{name: "John", age: 27, languages: ["Erlang", "Ruby", "Elixir"]},
  mary: %{name: "Mary", age: 29, languages: ["Elixir", "F#", "Clojure"]}
]

update_in users[:mary].languages, fn languages -> List.delete(languages, "Clojure") end

case {1, 2, 3} do
  {1, x, 3} when x > 0 ->
    "Will match"
  _ ->
    "Would match, if guard condition were not satisfied"
end

defmodule Math do
  @moduledoc """
  Provides math-related functions.

  ## Examples

      iex> Math.sum(1, 2)
      3

  """

  @initial_state %{host: "127.0.0.1", port: 3456}
  IO.inspect @initial_state

  @doc """
  Calculates the sum of two numbers.
  """
  def sum(a, b), do: a + b
  def zero?(0), do: true
  def zero?(x) when is_integer(x), do: false
end

h Math.sum

IO.gets "yes or no? "
IO.puts Math.sum 1, 3

defmodule Recursion do
  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts msg
  end

  def print_multiple_times(msg, n) do
    IO.puts msg
    print_multiple_times(msg, n - 1)
  end
end

Enum.reduce([1, 2, 3], 0, fn(x, acc) -> x + acc end)
Enum.reduce([1, 2, 3], 0, &+/2)

Enum.map([1, 2, 3], fn(x) -> x * 2 end)
Enum.map([1, 2, 3], &(&1 * 2))

1..100_000 |> Enum.map(&(&1 * 3))   |> Enum.filter(odd?)   |> Enum.sum
1..100_000 |> Stream.map(&(&1 * 3)) |> Stream.filter(odd?) |> Enum.sum

stream = Stream.cycle([1, 2, 3])
stream = Stream.unfold("hełło", &String.next_codepoint/1)
stream = File.stream!("path/to/file")
Enum.take(stream, 10)

case File.read "hello" do
  {:ok, body}      -> IO.puts "Success: #{body}"
  {:error, reason} -> IO.puts "Error: #{reason}"
end

Path.join("~", "foo") |> Path.expand

---

pid = spawn fn -> 1 + 2 end
{:ok, pid} = Task.start ...
Process.alive?(pid)
flush # For debugging.

send self(), {:hello, "world"}
receive do
  {:hello, msg} -> msg
  {:asdf, msg} -> "won't match"
  after 1_000 -> "nothing after 1s"
end

parent = self()
spawn fn -> send(parent, {:hello, self()}) end
receive do
  {:hello, pid} -> "Got hello from #{inspect pid}"
end

{:ok, pid} = Agent.start_link(fn -> %{} end)
Agent.update(pid, fn map -> Map.put(map, :hello, :world) end)
Agent.get(pid, fn map -> Map.get(map, :hello) end)

---

# Alias the module so it can be called as Bar instead of Foo.Bar
alias Foo.Bar, as: Bar
alias Foo.Bar # Exact same behavior
alias MyApp.{Foo, Bar, Baz}
:"Elixir.String" == String

# Require the module in order to use its macros (the public functions are globally available without require)
require Foo

# Import functions from Foo so they can be called without the `Foo.` prefix
import Foo
import Integer, only: :functions
import List, only: [duplicate: 2] # For List.duplicate/2

# Invokes the custom code defined in Foo as an extension point
use Foo
use ExUnit.Case, async: true # Calls Feature.__using__(option: :value)

---

defmodule User do
  @enforce_keys [:age]
  defstruct name: "John", age: 27
end

john = %User{}
meg = %User{name: "Meg"}
meg = %{john | name: "Meg"}

---

defprotocol Size do
  @doc "Calculates the size (and not the length!) of a data structure"
  @fallback_to_any true # Either this (not ideal)...
  def size(data)
end

defimpl Size, for: BitString do
  def size(string), do: byte_size(string)
end

defimpl Size, for: Any do
  def size(_), do: 0
end

defmodule User do
  @derive [Size] # ...or this.
  defstruct [:name, :age]
end

---

# Comprehension
for n <- [1, 2, 3, 4], do: n * n

values = [good: 1, good: 2, bad: 3, good: 4]
for {:good, n} <- values, do: n * n

multiple_of_3? = fn(n) -> rem(n, 3) == 0 end
for n <- 0..5, multiple_of_3?.(n), do: n * n

for i <- [:a, :b, :c], j <- [1, 2], do:  {i, j}
[a: 1, a: 2, b: 1, b: 2, c: 1, c: 2]

dirs = ['/home/mikey', '/home/james']
for dir  <- dirs,
    file <- File.ls!(dir),
    path = Path.join(dir, file),
    File.regular?(path) do
  File.stat!(path).size
end

defmodule Triple do
  def pythagorean(n) when n > 0 do
    for a <- 1..n,
        b <- 1..n,
        c <- 1..n,
        a + b + c <= n,
        a*a + b*b == c*c,
        do: {a, b, c}
  end
end

Triple.pythagorean(12)
[{3, 4, 5}, {4, 3, 5}]

# More efficient:
defmodule Triple do
  def pythagorean(n) when n > 0 do
    for a <- 1..n-2,
        b <- a+1..n-1,
        c <- b+1..n,
        a + b >= c,
        a*a + b*b == c*c,
        do: {a, b, c}
  end
end

pixels = <<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
for <<r::8, g::8, b::8 <- pixels>>, do: {r, g, b}
[{213, 45, 132}, {64, 76, 32}, {76, 0, 0}, {234, 32, 15}]

for <<c <- " hello world ">>, c != ?\s, into: "", do: <<c>>
"helloworld"

for {key, val} <- %{"a" => 1, "b" => 2}, into: %{}, do: {key, val * val}
%{"a" => 1, "b" => 4}

stream = IO.stream(:stdio, :line)
for line <- stream, into: stream do
  String.upcase(line) <> "\n"
end

---

# Sigils
regex = ~r/foo|bar/
"foo" =~ regex

~r/hello/
~r|hello|
~r"hello"
~r'hello'
~r(hello)
~r[hello]
~r{hello}
~r<hello>

~s(string)
~S(unescaped string #{this stays as is})
~c(chars)
~w(word list)
~w(atom list)a

@doc ~S"""
  ...
"""

# Equivalent:
~r/foo/i
sigil_r(<<"foo">>, 'i')

defmodule MySigils do
  def sigil_i(string, []), do: String.to_integer(string)
  def sigil_i(string, [?n]), do: -String.to_integer(string)
end

~i(42)n
-42

---

raise "oops" # RuntimeError
raise ArgumentError, message: "invalid argument foo"

defmodule MyError do
  defexception message: "default message"
end

try
rescue
after
catch
else

---

@spec round(number) :: integer
def round(x), do: ...

@type number_with_remark :: {number, String.t}

# Behaviours
defmodule Parser do
  @callback parse(String.t) :: {:ok, term} | {:error, String.t}
  @callback extensions() :: [String.t]

  # Dynamic dispatching
  def parse!(implementation, contents) do
    case implementation.parse(contents) do
      {:ok, data} -> data
      {:error, error} -> raise ArgumentError, "parsing error: #{error}"
    end
  end
end

defmodule JSONParser do
  @behaviour Parser
  ...
end

---

# Debugging

(1..10)
|> IO.inspect(label: "before")
|> Enum.map(&(&1 * 2))
|> IO.inspect(label: "after")

def some_fun(a, b, c) do
  IO.inspect binding()
  ...
  require IEx; IEx.pry
  ...
end

# Run iex in the context of a project:
iex -S mix TASK

break! URI.decode_query/2
URI.decode_query "test" %{}
whereami 20

https://hexdocs.pm/iex/IEx.Helpers.html#content

# GUI
:debugger.start
:observer.start

---

# Quote macro
# Function name, metadata, arguments.

quote do: sum(1, 2, 3)
{:sum, [], [1, 2, 3]}

quote do: %{1 => 2}
{:%{}, [], [{1, 2}]}

quote do: 1 + 2
{:+, [context: Elixir, import: Kernel], [1, 2]}

Macro.to_string(quote do: sum(1, 2 + 3, 4))
"sum(1, 2 + 3, 4)"

number = 13
Macro.to_string(quote do: 11 + unquote(number))
"11 + 13"

inner = [3, 4, 5]
Macro.to_string(quote do: [1, 2, unquote_splicing(inner), 6])
"[1, 2, 3, 4, 5, 6]"

Macro.escape(%{1 => 2})
{:%{}, [], [{1, 2}]}

# Identity (same when quoted and unquoted):
:foo         #=> Atoms
1.0          #=> Numbers
[1, 2]       #=> Lists
"strings"    #=> Strings
{key, value} #=> Tuples with two elements

---

# Macros receive quoted expressions and must return quoted expressions.

defmodule Unless do
  def fun_unless(clause, do: expression) do
    if !clause, do: expression
  end

  defmacro macro_unless(clause, do: expression) do
    quote do
      if !unquote(clause), do: unquote(expression)
    end
  end
end

Unless.macro_unless true, do: IO.puts "this should never be printed"

defmodule Sample do
  defmacro initialize_to_char_count(variables) do
    Enum.map variables, fn(name) ->
      var = Macro.var(name, nil)
      length = name |> Atom.to_string |> String.length
      quote do
        unquote(var) = unquote(length)
      end
    end
  end

  def run do
    initialize_to_char_count [:red, :green, :yellow]
    [red, green, yellow]
  end
end

Sample.run
[3, 5, 6]

---

# Domain-specific languages (DSL)

defmodule TestCase do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import TestCase

      # Initialize @tests to an empty list
      @tests []

      # Invoke TestCase.__before_compile__/1 before the module is compiled
      @before_compile TestCase
    end
  end

  @doc """
  Defines a test case with the given description.

  ## Examples

      test "arithmetic operations" do
        4 = 2 + 2
      end

  """
  defmacro test(description, do: block) do
    function_name = String.to_atom("test " <> description)
    quote do
      # Prepend the newly defined test to the list of tests
      @tests [unquote(function_name) | @tests]
      def unquote(function_name)(), do: unquote(block)
    end
  end

  # This will be invoked right before the target module is compiled
  # giving us the perfect opportunity to inject the `run/0` function
  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def run do
        Enum.each @tests, fn name ->
          IO.puts "Running #{name}"
          apply(__MODULE__, name, [])
        end
      end
    end
  end
end
