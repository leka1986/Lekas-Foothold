using System.Diagnostics;
using System.Text;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal static class LuaSyntaxValidatorRegressionSelfTest
{
    private sealed record SyntaxFixture(string Name, string Text, bool IsValid);

    private static readonly SyntaxFixture[] Fixtures =
    [
        new("simple table", "Settings = { enabled = true, count = 2 }\n", true),
        new("comments and expressions", "-- comment\nvalue = 1 + 2 * 3\n", true),
        new("long bracket string", "message = [=[line one\nline two]=]\n", true),
        new("Lua 5.1 numeric forms", "numbers = { 0x10, .5, 1e3 }\n", true),
        new("nested tables", "outer = { inner = { [\"key\"] = { 1, 2, 3 } } }\n", true),
        new("duplicate keys stay syntax-valid", "T = { [\"OH58D\"] = 1, [\"OH58D\"] = 2 }\n", true),
        new("double comma", "T = { a = 1,, b = 2 }\n", false),
        new("missing separator", "T = { a = 1 b = 2 }\n", false),
        new("unclosed table", "T = { a = 1\n", false),
        new("unterminated quote", "T = { a = \"broken }\n", false),
        new("extra quote", "value = \"ok\"\"\n", false),
        new("misplaced table row", "[\"Engineer soldier\"] = 2,\n", false),
        new("truncated long string", "message = [[broken\n", false),
        new("Lua 5.2 goto is rejected", "goto done\n::done::\n", false)
    ];

    internal static void Run(string tempDirectory)
    {
        foreach (var fixture in Fixtures)
        {
            var errors = LuaSyntaxValidator.Validate(fixture.Text, fixture.Name + ".lua");
            Require(fixture.IsValid ? errors.Count == 0 : errors.Count > 0,
                "Managed Lua validation returned the wrong validity for " + fixture.Name + ".");

            if (!fixture.IsValid)
            {
                Require(errors[0].StartsWith("Lua syntax:", StringComparison.Ordinal),
                    "Managed Lua validation did not prefix the diagnostic for " + fixture.Name + ".");
                Require(Regex.IsMatch(errors[0], @"\([1-9]\d*,[1-9]\d*\)"),
                    "Managed Lua validation did not provide a one-based (line,column) position for " + fixture.Name + ".");
            }
        }

        VerifyValidationDoesNotExecuteLua(tempDirectory);
        VerifyInternalParserFailureDoesNotExposeSensitiveDetails();
        VerifyParserDiagnosticsAreCappedInOriginalOrder();
        VerifyLuacOracleAsync(tempDirectory).GetAwaiter().GetResult();
    }

    private static void VerifyValidationDoesNotExecuteLua(string tempDirectory)
    {
        var markerPath = Path.Combine(tempDirectory, "validation-must-not-execute.marker");
        var text = "local marker = [=[" + markerPath + "]=]\n" +
                   "io.open(marker, \"w\")\n";

        var errors = LuaSyntaxValidator.Validate(text, "no-execution.lua");
        Require(errors.Count == 0, "Managed Lua validation rejected the no-execution fixture.");
        Require(!File.Exists(markerPath), "Managed Lua validation executed the no-execution fixture.");
    }

    private static void VerifyInternalParserFailureDoesNotExposeSensitiveDetails()
    {
        const string sourceText = "secret source text";
        const string exceptionMessage = "secret injected parser failure";

        var errors = LuaSyntaxValidator.ValidateCore(
            sourceText,
            "internal-failure.lua",
            (_, _) => throw new InvalidOperationException(exceptionMessage));

        Require(errors.Count == 1 && errors[0].StartsWith("Lua syntax validation failed internally", StringComparison.Ordinal),
            "Managed Lua validation did not return the safe internal-failure diagnostic.");
        Require(!errors[0].Contains(sourceText, StringComparison.Ordinal) &&
                !errors[0].Contains(exceptionMessage, StringComparison.Ordinal),
            "Managed Lua validation exposed source text or an injected exception message.");
    }

    private static void VerifyParserDiagnosticsAreCappedInOriginalOrder()
    {
        var expected = Enumerable.Range(0, 80)
            .Select(index => "Lua syntax: generated diagnostic " + index)
            .ToList();

        var errors = LuaSyntaxValidator.ValidateCore(
            "value = 1\n",
            "diagnostic-cap.lua",
            (_, _) => expected);

        Require(errors.Count == 50, "Managed Lua validation did not cap parser diagnostics at 50.");
        Require(errors.SequenceEqual(expected.Take(50)),
            "Managed Lua validation changed parser diagnostic order while applying the cap.");
    }

    private static async Task VerifyLuacOracleAsync(string tempDirectory)
    {
        var oraclePath = Environment.GetEnvironmentVariable("FOOTHOLD_CONFIG_MANAGER_LUAC_ORACLE");
        if (string.IsNullOrWhiteSpace(oraclePath))
        {
            Console.WriteLine("Lua syntax oracle skipped: FOOTHOLD_CONFIG_MANAGER_LUAC_ORACLE is not set.");
            return;
        }

        for (var fixtureIndex = 0; fixtureIndex < Fixtures.Length; fixtureIndex++)
        {
            var fixture = Fixtures[fixtureIndex];
            var fixturePath = Path.Combine(tempDirectory, "luac-oracle-" + fixtureIndex + ".lua");
            File.WriteAllText(fixturePath, fixture.Text, new UTF8Encoding(false));

            using var process = Process.Start(new ProcessStartInfo
            {
                FileName = oraclePath,
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                ArgumentList = { "-p", fixturePath }
            }) ?? throw new InvalidOperationException("Could not start the configured luac oracle.");
            var standardOutputTask = process.StandardOutput.ReadToEndAsync();
            var standardErrorTask = process.StandardError.ReadToEndAsync();
            process.WaitForExit();
            await Task.WhenAll(standardOutputTask, standardErrorTask);

            var oracleIsValid = process.ExitCode == 0;
            var managedIsValid = LuaSyntaxValidator.Validate(fixture.Text, fixture.Name + ".lua").Count == 0;
            Require(oracleIsValid == fixture.IsValid,
                "luac oracle returned the wrong validity for " + fixture.Name + ".");
            Require(managedIsValid == fixture.IsValid && managedIsValid == oracleIsValid,
                "Managed Lua validation disagreed with the luac oracle for " + fixture.Name + ".");
        }
    }

    private static void Require(bool condition, string message)
    {
        if (!condition)
        {
            throw new InvalidOperationException(message);
        }
    }
}
