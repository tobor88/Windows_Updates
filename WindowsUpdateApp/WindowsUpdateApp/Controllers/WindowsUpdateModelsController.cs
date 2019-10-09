using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WindowsUpdateTracker.Models;

namespace WindowsUpdateTracker.Controllers
{
    public class WindowsUpdateModelsController : Controller
    {
        private readonly WindowsUpdateTrackerContext _context;

        public WindowsUpdateModelsController(WindowsUpdateTrackerContext context)
        {
            _context = context;
        }

        // GET: WindowsUpdateModels
        public async Task<IActionResult> Index()
        {
            return View(await _context.WindowsUpdateModel.ToListAsync());
        }

        // GET: WindowsUpdateModels/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var windowsUpdateModel = await _context.WindowsUpdateModel
                .FirstOrDefaultAsync(m => m.ID == id);
            if (windowsUpdateModel == null)
            {
                return NotFound();
            }

            return View(windowsUpdateModel);
        }

        // GET: WindowsUpdateModels/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: WindowsUpdateModels/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("ID,UpdateTitle,HostName,Date,DownloadStatus,InstallStatus")] WindowsUpdateModel windowsUpdateModel)
        {
            if (ModelState.IsValid)
            {
                _context.Add(windowsUpdateModel);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(windowsUpdateModel);
        }

        // GET: WindowsUpdateModels/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var windowsUpdateModel = await _context.WindowsUpdateModel.FindAsync(id);
            if (windowsUpdateModel == null)
            {
                return NotFound();
            }
            return View(windowsUpdateModel);
        }

        // POST: WindowsUpdateModels/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("ID,UpdateTitle,HostName,Date,DownloadStatus,InstallStatus")] WindowsUpdateModel windowsUpdateModel)
        {
            if (id != windowsUpdateModel.ID)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(windowsUpdateModel);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!WindowsUpdateModelExists(windowsUpdateModel.ID))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            return View(windowsUpdateModel);
        }

        // GET: WindowsUpdateModels/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var windowsUpdateModel = await _context.WindowsUpdateModel
                .FirstOrDefaultAsync(m => m.ID == id);
            if (windowsUpdateModel == null)
            {
                return NotFound();
            }

            return View(windowsUpdateModel);
        }

        // POST: WindowsUpdateModels/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var windowsUpdateModel = await _context.WindowsUpdateModel.FindAsync(id);
            _context.WindowsUpdateModel.Remove(windowsUpdateModel);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool WindowsUpdateModelExists(int id)
        {
            return _context.WindowsUpdateModel.Any(e => e.ID == id);
        }
    }
}
