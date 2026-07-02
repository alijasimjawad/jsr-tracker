const webpush = require('web-push');

webpush.setVapidDetails(
  'mailto:ali.jawad.ext@gmail.com',
  'BNRkBW0K1lpB3W10b1uQgrqKRFL2GMGFrOF4ECkpIDcaFYXowjqqdbvJA2RoWU-smR7wip_bVdO91ksfZPeSoPo',
  '7V9TxUp62oVctC0MwFkGJZvLHh0X4eljN6ROOQbtaWw'
);

module.exports = async (req, res) => {
  if (req.method !== 'POST') return res.status(405).end();
  const { subscription, title, body, url } = req.body;
  try {
    await webpush.sendNotification(
      subscription,
      JSON.stringify({ title, body, url: url || 'https://tracker.jsr-iq.net' })
    );
    res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};
