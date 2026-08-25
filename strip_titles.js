const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, 'lib/widgets/charts/screens');
const files = fs.readdirSync(dir).filter(f => f.endsWith('.dart') && f !== 'chart_screen_helpers.dart');

files.forEach(f => {
  const filePath = path.join(dir, f);
  let code = fs.readFileSync(filePath, 'utf8');

  // We want to remove the block:
  // Padding(
  //   padding: const EdgeInsets.all(16.0),
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(config.title, ...),
  //       if (config.subtitle.isNotEmpty) ...[
  //         ...
  //       ],
  //     ],
  //   ),
  // ),

  // The regex will match from `Padding(\n          padding: const EdgeInsets.all(16.0),`
  // up to the closing `),` before the next `Expanded(` or similar.

  const regex = /Padding\(\s*padding:\s*const EdgeInsets\.all\(16\.0\),\s*child:\s*Column\([\s\S]*?crossAxisAlignment:\s*CrossAxisAlignment\.start,[\s\S]*?Text\(config\.title[\s\S]*?\]\s*,\s*\)\s*,\s*\),/g;
  
  if (regex.test(code)) {
    code = code.replace(regex, '');
    fs.writeFileSync(filePath, code, 'utf8');
    console.log('Stripped titles from ' + f);
  } else {
    // Also try checking for `config.title` generally
    const titleRegex = /Padding\(\s*padding:\s*const EdgeInsets\.all\(16\.0\),\s*child:\s*Column\([\s\S]*?children:\s*\[\s*Text\(\s*config\.title[\s\S]*?\]\s*,\s*\)\s*,\s*\),/g;
    if (titleRegex.test(code)) {
      code = code.replace(titleRegex, '');
      fs.writeFileSync(filePath, code, 'utf8');
      console.log('Stripped titles from ' + f + ' (alt regex)');
    }
  }
});
