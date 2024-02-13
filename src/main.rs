use clap::Command;
use nixjs::cmd;
use std::process::ExitCode;

fn main() -> ExitCode {
    let mut cmd = Command::new("nixjs")
        .version("0.0.1")
        .about("Nix Javascript transpiler and interpreter.")
        .arg_required_else_help(true);

    let subcommands = &[&cmd::eval::cmd(), &cmd::transpile::cmd()];

    for subcommand in subcommands {
        cmd = cmd.subcommand((subcommand.cmd)(Command::new(subcommand.name)));
    }

    dispatch_cmd(&cmd.get_matches(), subcommands)
}

fn dispatch_cmd(parsed_args: &clap::ArgMatches, subcommands: &[&cmd::NixJSSubCommand]) -> ExitCode {
    for subcommand in subcommands {
        if let Some(subcommand_args) = parsed_args.subcommand_matches(subcommand.name) {
            return (subcommand.handler)(subcommand_args)
                .map_or_else(|err| err, |_| ExitCode::SUCCESS);
        }
    }
    cmd::print_and_err("operation not supported")
}
