
const express = require("express");
const { createClient } = require("@supabase/supabase-js");

const router = express.Router();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_PUBLISHABLE_KEY;

console.log("MEDICATION ROUTES FILE LOADED");

async function authenticateUser(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Authentication token is required."
      });
    }

    const token = authHeader.substring(7);

    const authClient = createClient(supabaseUrl, supabaseKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });

    const { data, error } = await authClient.auth.getUser(token);

    if (error || !data.user) {
      return res.status(401).json({
        success: false,
        message: "Invalid or expired authentication token."
      });
    }

    req.user = data.user;
    req.accessToken = token;

    next();
  } catch (error) {
    next(error);
  }
}

router.get("/tracking", authenticateUser, async (req, res) => {
  try {
    const date = req.query.date;

    if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      return res.status(400).json({
        success: false,
        message: "A valid date is required (YYYY-MM-DD).",
      });
    }

    const supabase = createClient(
      supabaseUrl,
      supabaseKey,
      {
        global: {
          headers: {
            Authorization: `Bearer ${req.accessToken}`,
          },
        },
      }
    );

    const { data, error } = await supabase
      .from("medication_logs")
      .select("*")
      .eq("user_id", req.user.id)
      .eq("scheduled_date", date);

    if (error) throw error;

    return res.json({
      success: true,
      logs: data ?? [],
    });
  } catch (error) {
    console.error("GET TRACKING ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to retrieve medication tracking.",
    });
  }
});

router.patch("/:id/tracking", authenticateUser, async (req, res) => {
  try {
    const { date, time, is_taken } = req.body;
    const medicationId = req.params.id;

    if (
      !date ||
      !/^\d{4}-\d{2}-\d{2}$/.test(date) ||
      !time ||
      !/^([01]\d|2[0-3]):[0-5]\d$/.test(time) ||
      typeof is_taken !== "boolean"
    ) {
      return res.status(400).json({
        success: false,
        message: "Valid date, time, and is_taken are required.",
      });
    }

    const supabase = createClient(
      supabaseUrl,
      supabaseKey,
      {
        global: {
          headers: {
            Authorization: `Bearer ${req.accessToken}`,
          },
        },
      }
    );

    // Verify that this medication belongs to the logged-in user.
    const { data: medication, error: medicationError } = await supabase
      .from("medications")
      .select("id")
      .eq("id", medicationId)
      .eq("user_id", req.user.id)
      .maybeSingle();

    if (medicationError) throw medicationError;

    if (!medication) {
      return res.status(404).json({
        success: false,
        message: "Medication not found.",
      });
    }

    const { data, error } = await supabase
      .from("medication_logs")
      .upsert(
        {
          user_id: req.user.id,
          medication_id: medicationId,
          scheduled_date: date,
          scheduled_time: time,
          is_taken,
          taken_at: is_taken ? new Date().toISOString() : null,
        },
        {
          onConflict:
            "user_id,medication_id,scheduled_date,scheduled_time",
        }
      )
      .select()
      .single();

    if (error) throw error;

    return res.json({
      success: true,
      message: is_taken
        ? "Medication marked as taken."
        : "Medication marked as not taken.",
      log: data,
    });
  } catch (error) {
    console.error("UPDATE TRACKING ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update medication tracking.",
    });
  }
});

router.get('/', authenticateUser, async (req, res) => {
  try {
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_PUBLISHABLE_KEY,
      {
        global: {
          headers: {
            Authorization: `Bearer ${req.accessToken}`,
          },
        },
      }
    );

    const { data, error } = await supabase
      .from('medications')
      .select('*')
      .eq('user_id', req.user.id)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('GET MEDICATIONS ERROR:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to retrieve medications.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Medications retrieved successfully.',
      medications: data ?? [],
    });
  } catch (error) {
    console.error('GET MEDICATIONS ERROR:', error);

    return res.status(500).json({
      success: false,
      message: 'An error occurred while retrieving medications.',
    });
  }
});

router.patch("/:id/taken", authenticateUser, async (req, res, next) => {
  try {
    const userSupabase = createClient(supabaseUrl, supabaseKey, {
      global: {
        headers: {
          Authorization: `Bearer ${req.accessToken}`
        }
      },
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });

    const { data, error } = await userSupabase
      .from("medications")
      .update({ is_taken: true })
      .eq("id", req.params.id)
      .eq("user_id", req.user.id)
      .select()
      .single();

    if (error) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    return res.status(200).json({
      success: true,
      message: "Medication marked as taken.",
      medication: data
    });

  } catch (error) {
    next(error);
  }
});

router.post("/", authenticateUser, async (req, res, next) => {
  try {
    const {
      name,
      bentuk_obat,
      jumlah,
      jumlah_per_minum,
      frequency,
      is_as_needed,
      times
    } = req.body;

    if (
      typeof name !== "string" ||
      !name.trim() ||
      typeof bentuk_obat !== "string" ||
      !bentuk_obat.trim()
    ) {
      return res.status(400).json({
        success: false,
        message: "Medication name and form are required."
      });
    }

    const totalAmount = Number(jumlah);
    const amountPerDose = Number(jumlah_per_minum);
    const dailyFrequency = Number(frequency);

    if (
      !Number.isFinite(totalAmount) ||
      totalAmount <= 0 ||
      !Number.isFinite(amountPerDose) ||
      amountPerDose <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Medication quantities must be positive numbers."
      });
    }

    if (
      !Number.isInteger(dailyFrequency) ||
      dailyFrequency < 0 ||
      dailyFrequency > 12
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid medication frequency."
      });
    }

    if (typeof is_as_needed !== "boolean" || !Array.isArray(times)) {
      return res.status(400).json({
        success: false,
        message: "Invalid medication schedule."
      });
    }

    const validTime = (time) =>
      typeof time === "string" &&
      /^([01]\d|2[0-3]):[0-5]\d$/.test(time);

    if (!times.every(validTime)) {
      return res.status(400).json({
        success: false,
        message: "Invalid medication time format. Use HH:mm."
      });
    }

    if (is_as_needed && times.length !== 0) {
      return res.status(400).json({
        success: false,
        message: "As-needed medication should not have fixed times."
      });
    }

    if (!is_as_needed && times.length !== dailyFrequency) {
      return res.status(400).json({
        success: false,
        message: "The number of times must match the daily frequency."
      });
    }

    const userSupabase = createClient(supabaseUrl, supabaseKey, {
      global: {
        headers: {
          Authorization: `Bearer ${req.accessToken}`
        }
      },
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });

    const { data, error } = await userSupabase
      .from("medications")
      .insert({
        user_id: req.user.id,
        name: name.trim(),
        bentuk_obat: bentuk_obat.trim(),
        jumlah: totalAmount,
        jumlah_per_minum: amountPerDose,
        frequency: dailyFrequency,
        is_as_needed,
        times
      })
      .select()
      .single();

    if (error) {
      console.error("SAVE MEDICATION ERROR:", error);

      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    return res.status(201).json({
      success: true,
      message: "Medication saved successfully.",
      medication: data
    });

  } catch (error) {
    next(error);
  }
});

module.exports = router;
