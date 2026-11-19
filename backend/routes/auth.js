const express = require("express");
const { createClient } = require("@supabase/supabase-js");

const router = express.Router();

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_PUBLISHABLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
      detectSessionInUrl: false
    }
  }
);

function normalizeEmail(email) {
  return typeof email === "string" ? email.trim().toLowerCase() : "";
}

function validEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

router.post("/register", async (req, res, next) => {
    console.log("REGISTER ROUTE REACHED!");
  try {
    const name = typeof req.body.name === "string" ? req.body.name.trim() : "";
    const email = normalizeEmail(req.body.email);
    const password = typeof req.body.password === "string" ? req.body.password : "";

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Name, email, and password are required."
      });
    }

    if (!validEmail(email)) {
      return res.status(400).json({
        success: false,
        message: "Please enter a valid email address."
      });
    }

    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        message: "Password must contain at least 8 characters."
      });
    }
    
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: name
        }
      }
    });

    console.log("SUPABASE SIGNUP RESULT:", {
        userCreated: !!data?.user,
        sessionCreated: !!data?.session,
        error: error?.message ?? null
    });
    
    if (error) {
        console.error("SUPABASE FULL ERROR:", {
            message: error.message,
            status: error.status,
            code: error.code,
            name: error.name,
            details: error.details,
            hint: error.hint
        });

        return res.status(400).json({
            success: false,
            message: error.message,
            code: error.code
        });
    }
    

    return res.status(201).json({
      success: true,
      message: data.session
        ? "Registration successful."
        : "Account created. Please check your email to confirm your account.",
      user: data.user
        ? {
            id: data.user.id,
            email: data.user.email,
            name: data.user.user_metadata?.full_name ?? name
          }
        : null,
      session: data.session
        ? {
            access_token: data.session.access_token,
            refresh_token: data.session.refresh_token,
            expires_at: data.session.expires_at,
            token_type: data.session.token_type
          }
        : null
    });
  } catch (error) {
    next(error);
  }
});

router.post("/login", async (req, res, next) => {
  try {
    const email = normalizeEmail(req.body.email);
    const password = typeof req.body.password === "string" ? req.body.password : "";

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required."
      });
    }

    if (!validEmail(email)) {
      return res.status(400).json({
        success: false,
        message: "Please enter a valid email address."
      });
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (error) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password."
      });
    }

    return res.status(200).json({
      success: true,
      message: "Login successful.",
      user: {
        id: data.user.id,
        email: data.user.email,
        name: data.user.user_metadata?.full_name ?? "",
        user_metadata: data.user.user_metadata ?? {}
      },
      session: {
        access_token: data.session.access_token,
        refresh_token: data.session.refresh_token,
        expires_at: data.session.expires_at,
        token_type: data.session.token_type
      }
    });
  } catch (error) {
    next(error);
  }
});


router.patch("/onboarding/complete", async (req, res) => {
  console.log("ONBOARDING COMPLETION ROUTE REACHED!");

  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Authentication token is required."
      });
    }

    const token = authHeader.substring(7);

    // 1. Verify the authenticated user.
    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data.user) {
      return res.status(401).json({
        success: false,
        message: "Invalid or expired authentication token."
      });
    }

    // 2. Update the user's metadata in Supabase Auth.
    const response = await fetch(
      `${process.env.SUPABASE_URL}/auth/v1/user`,
      {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          "apikey": process.env.SUPABASE_PUBLISHABLE_KEY,
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
          data: {
            onboarding_completed: true
          }
        })
      }
    );

    // 3. Read the response safely.
    const responseText = await response.text();

    console.log("SUPABASE ONBOARDING STATUS:", response.status);
    console.log("SUPABASE ONBOARDING RESPONSE:", responseText);

    let result = {};

    if (responseText.trim()) {
      try {
        result = JSON.parse(responseText);
      } catch {
        console.error("Supabase returned an invalid JSON response.");
      }
    }

    if (!response.ok) {
      return res.status(400).json({
        success: false,
        message: result.message ||
          result.msg ||
          "Failed to update onboarding status."
      });
    }

    // 4. Success.
    return res.status(200).json({
      success: true,
      message: "Onboarding completed successfully."
    });

  } catch (error) {
    console.error("ONBOARDING ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to complete onboarding."
    });
  }
});


module.exports = router;
