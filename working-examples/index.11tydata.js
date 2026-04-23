import { glob } from "tinyglobby";

export default async () => {
  const filenames = await glob("*/**/*.html", { cwd: "working-examples" });
  return {
    files: filenames.map((filename) => ({
      filename,
      label: filename.replace(/(\/?index)?\.html$/, ""),
    })),
  };
};
