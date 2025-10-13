# Privacy Policy Setup Guide for App Store Connect

## Step-by-Step Instructions

### Option 1: GitHub Pages (Recommended - Free & Easy)

#### 1. Enable GitHub Pages
1. Go to your repository: https://github.com/dunsinagb/timefill
2. Click **Settings** tab
3. Scroll down to **Pages** section (left sidebar)
4. Under **Source**, select:
   - Branch: `master`
   - Folder: `/root`
5. Click **Save**
6. Wait 1-2 minutes for deployment

#### 2. Your Privacy Policy URL
After GitHub Pages is enabled, your privacy policy will be available at:

```
https://dunsinagb.github.io/timefill/privacy-policy.html
```

**Test it**: Open this URL in your browser to verify it loads correctly.

#### 3. Add to App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app (TimeFill)
3. Go to **App Information** section
4. Scroll to **Privacy Policy URL**
5. Enter: `https://dunsinagb.github.io/timefill/privacy-policy.html`
6. Click **Save**

✅ **Done!** Your privacy policy is now publicly accessible and linked in App Store Connect.

---

### Option 2: Alternative Free Hosting Services

If you don't want to use GitHub Pages, here are alternatives:

#### Netlify (Free, Drag & Drop)
1. Go to [Netlify.com](https://www.netlify.com)
2. Sign up (free)
3. Drag and drop the `privacy-policy.html` file
4. You'll get a URL like: `https://timefill-privacy.netlify.app`
5. Use this URL in App Store Connect

#### Vercel (Free, Simple)
1. Go to [Vercel.com](https://vercel.com)
2. Sign up (free)
3. Upload the `privacy-policy.html` file
4. You'll get a URL like: `https://timefill-privacy.vercel.app`
5. Use this URL in App Store Connect

#### Your Own Domain (If you have one)
1. Upload `privacy-policy.html` to your web hosting
2. Access at: `https://yourdomain.com/privacy-policy.html`
3. Use this URL in App Store Connect

---

## App Store Connect Privacy Details

When filling out App Store Connect privacy information, answer as follows:

### Data Collection
**Does this app collect data from users?**
- Answer: **NO**

### Tracking
**Does this app track users?**
- Answer: **NO**

### Data Types Used to Track You
- **None selected** (leave all unchecked)

### Data Linked to You
- **None selected** (leave all unchecked)

### Data Not Linked to You
- **None selected** (leave all unchecked)

### Privacy Practices for Third-Party Code
- Answer: **We do not use third-party code**
- Or if required to answer about third-party SDKs: **No third-party SDKs are used**

---

## Privacy Nutrition Label Summary

Your app's privacy nutrition label will show:

```
Data Not Collected

The developer does not collect any data from this app.
```

This is the **best possible** privacy label an app can have! ✅

---

## Important Notes

### For App Review
1. Apple may ask to verify that you truly don't collect data
2. They may test the app to confirm
3. Your code is clean - you'll pass review easily

### Future Updates
If you ever add data collection in the future:
1. Update `PRIVACY_POLICY.md`
2. Regenerate `privacy-policy.html`
3. Commit and push to GitHub
4. The URL stays the same (automatically updates)
5. Update App Store Connect privacy details

### Email in Privacy Policy
The privacy policy includes your email: `agbolaboridunsin@gmail.com`

If you want to change this:
1. Edit both `PRIVACY_POLICY.md` and `privacy-policy.html`
2. Search for the email address
3. Replace with your preferred contact method
4. Commit and push changes

---

## Verification Checklist

Before submitting to App Store:

- [ ] Privacy policy accessible at public URL
- [ ] URL entered in App Store Connect
- [ ] Privacy policy loads correctly in browser
- [ ] "Data Not Collected" selected in App Store Connect
- [ ] No tracking enabled in App Store Connect
- [ ] Email in privacy policy is correct
- [ ] Last updated date is correct (October 13, 2025)

---

## Example: Filling Out App Privacy in App Store Connect

### Section 1: Data Collection
**Question**: Does this app collect data from users?
**Answer**: No *(Then you're done!)*

That's it! Since you answered "No", you don't need to fill out any other sections.

---

## If Apple Requests More Information

If Apple's review team asks about specific permissions:

### Notifications
- **Purpose**: To send reminders for countdown events
- **Data collected**: None
- **Data stored**: Locally on device
- **Data shared**: Never

### Calendar
- **Purpose**: To import event dates as countdowns
- **Data collected**: Only event name and date (user-selected)
- **Data stored**: Locally on device
- **Data shared**: Never

### App Group (for Widgets)
- **Purpose**: Share countdown data between app and widgets
- **Data collected**: None
- **Data stored**: Locally on device (App Group container)
- **Data shared**: Never (stays on device)

---

## Support URL (Also Required)

Apple also requires a **Support URL**. Options:

1. **GitHub Issues** (Free):
   ```
   https://github.com/dunsinagb/timefill/issues
   ```

2. **Email Link**:
   ```
   mailto:agbolaboridunsin@gmail.com
   ```

3. **Simple Support Page** (I can create this too if needed)

Recommended: Use GitHub Issues URL - it's professional and free.

---

## Final URLs for App Store Connect

**Privacy Policy URL**:
```
https://dunsinagb.github.io/timefill/privacy-policy.html
```

**Support URL**:
```
https://github.com/dunsinagb/timefill/issues
```

**Marketing URL** (Optional):
```
https://github.com/dunsinagb/timefill
```

---

## Questions?

If you have any questions about the privacy policy setup, reach out before submitting to App Store.

Remember: Your app's privacy-first approach is a **major selling point**. Emphasize it in your App Store description!

✅ **You're ready to submit to App Store!**
